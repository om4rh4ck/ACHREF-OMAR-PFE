import { CommonModule } from '@angular/common';
import { Component, DestroyRef, OnInit, computed, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute } from '@angular/router';
import { interval } from 'rxjs';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { AppShellComponent } from '../components/app-shell.component';
import { UiIconComponent } from '../components/ui-icon.component';
import { Message, User } from '../models';
import { ApiService } from '../services/api.service';
import { AuthService } from '../services/auth.service';

interface Conversation {
  otherUserId: number;
  otherUserName: string;
  lastMessage: Message;
  hasUnread: boolean;
  waitingForReply: boolean;
}

@Component({
  selector: 'app-messages-page',
  standalone: true,
  imports: [CommonModule, FormsModule, AppShellComponent, UiIconComponent],
  template: `
    <app-shell [user]="auth.user()" title="Messagerie interne" (logout)="auth.logout()">
      <div class="panel-grid">
        <section class="section-card">
          <div class="section-heading">
            <div>
              <p class="eyebrow">Conversations</p>
              <h2 class="section-title">Messages recents</h2>
            </div>
          </div>

          <div class="stack-list">
            <article
              class="stack-item stack-item-clickable"
              *ngFor="let conv of conversations()"
              [class.selected]="selectedConversationId() === conv.otherUserId"
              [class.conv-unread]="conv.hasUnread"
              (click)="openConversation(conv.otherUserId)"
            >
              <div class="message-bubble">
                <div class="d-flex justify-content-between align-items-start gap-2">
                  <div class="d-flex align-items-center gap-2">
                    <span class="avatar-pill">
                      <ng-container *ngIf="avatarOfId(conv.otherUserId); else convFallback">
                        <img [src]="avatarOfId(conv.otherUserId)" alt="Profil" />
                      </ng-container>
                      <ng-template #convFallback>{{ initialsForName(conv.otherUserName) }}</ng-template>
                    </span>
                    <div class="fw-semibold">{{ conv.otherUserName }}</div>
                  </div>
                  <span class="message-state-badge" *ngIf="conv.hasUnread">Nouveau</span>
                  <span class="message-state-badge is-muted" *ngIf="!conv.hasUnread && conv.waitingForReply">A repondre</span>
                </div>
                <div class="conversation-preview" [class.is-unread]="conv.hasUnread">
                  {{ conv.lastMessage.content | slice:0:60 }}{{ conv.lastMessage.content.length > 60 ? '...' : '' }}
                </div>
                <div class="message-meta">{{ conv.lastMessage.created_at | date:'dd/MM/yyyy HH:mm' }}</div>
              </div>
            </article>
            <div class="empty-state" *ngIf="!conversations().length">Aucun message disponible.</div>
          </div>
        </section>

        <section class="section-card">
          <ng-container *ngIf="selectedConversationId(); else newMessageForm">
            <div class="section-heading d-flex justify-content-between align-items-center flex-wrap gap-2">
              <div>
                <p class="eyebrow">Discussion</p>
                <h2 class="section-title">{{ getOtherUserName(selectedConversationId()!) }}</h2>
              </div>
            </div>

            <div class="conversation-thread messenger-thread">
              <div class="chat-row" *ngFor="let msg of threadMessages()" [class.sent]="isSentByMe(msg)">
                <span class="avatar-pill" *ngIf="!isSentByMe(msg)">
                  <ng-container *ngIf="avatarOfId(msg.sender_id); else recvFallback">
                    <img [src]="avatarOfId(msg.sender_id)" alt="Profil" />
                  </ng-container>
                  <ng-template #recvFallback>{{ initialsForName(getOtherUserName(msg.sender_id)) }}</ng-template>
                </span>

                <div class="chat-bubble" [class.sent]="isSentByMe(msg)" [class.received-unread]="isUnreadIncoming(msg)">
                  <div class="chat-name">{{ isSentByMe(msg) ? 'Moi' : getOtherUserName(msg.sender_id) }}</div>
                  <div class="chat-text">{{ msg.content }}</div>
                  <div class="message-meta">
                    {{ msg.created_at | date:'dd/MM/yyyy HH:mm' }}
                    <span *ngIf="isUnreadIncoming(msg)"> | Nouveau</span>
                    <span *ngIf="!isSentByMe(msg) && !isUnreadIncoming(msg)"> | Recu</span>
                    <span *ngIf="isSentByMe(msg)"> | Envoye</span>
                  </div>
                </div>

                <span class="avatar-pill" *ngIf="isSentByMe(msg)">
                  <ng-container *ngIf="currentAvatar(); else meFallback">
                    <img [src]="currentAvatar()" alt="Moi" />
                  </ng-container>
                  <ng-template #meFallback>{{ initialsForName(auth.user()?.full_name) }}</ng-template>
                </span>
              </div>
            </div>

            <form class="mt-3" (ngSubmit)="sendReply()">
              <div class="mb-2">
                <textarea class="form-control app-input" [(ngModel)]="form.content" name="content" rows="3" placeholder="Votre reponse..." required></textarea>
              </div>
              <button class="primary-btn" type="submit">Repondre</button>
            </form>
          </ng-container>

          <ng-template #newMessageForm>
            <div class="section-heading">
              <div>
                <p class="eyebrow">Nouveau message</p>
                <h2 class="section-title">Contacter un collaborateur</h2>
              </div>
            </div>

            <form class="row g-3" (ngSubmit)="sendMessage()">
              <div class="col-12">
                <div class="search-input">
                  <span class="search-icon"><app-ui-icon name="search" /></span>
                  <input class="form-control app-input" [(ngModel)]="searchTermValue" (ngModelChange)="searchTerm.set($event)" name="search" placeholder="Rechercher un collaborateur..." />
                </div>
              </div>
              <div class="col-12">
                <div class="contact-list">
                  <div
                    class="contact-item"
                    *ngFor="let user of filteredRecipients()"
                    [class.is-selected]="form.receiver_id === user.id"
                    (click)="selectRecipient(user.id)"
                  >
                    <span class="avatar-pill">
                      <ng-container *ngIf="avatarOf(user); else fallbackAvatar">
                        <img [src]="avatarOf(user)" alt="Profil" />
                      </ng-container>
                      <ng-template #fallbackAvatar>{{ initialsFor(user) }}</ng-template>
                    </span>
                    <div class="contact-meta">
                      <div class="fw-semibold">{{ user.full_name }}</div>
                      <div class="contact-role">{{ user.role }} · {{ user.department || 'N/A' }}</div>
                    </div>
                  </div>
                  <div class="empty-state" *ngIf="!filteredRecipients().length">Aucun destinataire.</div>
                </div>
              </div>
              <div class="col-12">
                <textarea class="form-control app-input" [(ngModel)]="form.content" name="content" rows="7" placeholder="Votre message" required></textarea>
              </div>
              <div class="col-12">
                <button class="primary-btn w-100" type="submit">Envoyer</button>
              </div>
            </form>
          </ng-template>
        </section>
      </div>
    </app-shell>
  `
})
export class MessagesPageComponent implements OnInit {
  readonly auth = inject(AuthService);
  private readonly api = inject(ApiService);
  private readonly route = inject(ActivatedRoute);
  private readonly destroyRef = inject(DestroyRef);

  readonly messages = signal<Message[]>([]);
  readonly recipients = signal<User[]>([]);
  readonly usersMap = signal<Map<number, string>>(new Map());
  readonly usersById = signal<Map<number, User>>(new Map());
  readonly selectedConversationId = signal<number | null>(null);
  readonly searchTerm = signal('');
  searchTermValue = '';

  readonly form = {
    receiver_id: 0,
    content: ''
  };

  private pendingReceiverId: number | null = null;

  readonly filteredRecipients = computed<User[]>(() => {
    const term = this.searchTerm().trim().toLowerCase();
    const list = this.recipients();
    if (!term) return list;
    return list.filter((u) =>
      [u.full_name, u.email, u.role, u.department, u.position]
        .some((value) => (value ?? '').toLowerCase().includes(term))
    );
  });

  readonly conversations = computed<Conversation[]>(() => {
    const msgs = this.messages();
    const myId = this.auth.user()?.id;
    const users = this.usersMap();
    if (!myId || !msgs.length) return [];

    const byOther = new Map<number, Message[]>();
    for (const m of msgs) {
      const otherId = m.sender_id === myId ? m.receiver_id : m.sender_id;
      if (!byOther.has(otherId)) byOther.set(otherId, []);
      byOther.get(otherId)!.push(m);
    }

    return Array.from(byOther.entries()).map(([otherUserId, ms]) => {
      const sorted = [...ms].sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
      const last = sorted[0];
      const otherName = last.sender_id === myId
        ? (users.get(last.receiver_id) ?? 'Utilisateur')
        : (last.sender_name ?? users.get(last.sender_id) ?? 'Utilisateur');
      const hasUnread = ms.some((m) => m.receiver_id === myId && m.is_read !== true);
      const waitingForReply = last.receiver_id === myId;
      return { otherUserId, otherUserName: otherName, lastMessage: last, hasUnread, waitingForReply };
    }).sort((a, b) => new Date(b.lastMessage.created_at).getTime() - new Date(a.lastMessage.created_at).getTime());
  });

  readonly threadMessages = computed<Message[]>(() => {
    const sel = this.selectedConversationId();
    const msgs = this.messages();
    const myId = this.auth.user()?.id;
    if (!sel || !myId) return [];
    return msgs
      .filter((m) => (m.sender_id === sel && m.receiver_id === myId) || (m.receiver_id === sel && m.sender_id === myId))
      .sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());
  });

  ngOnInit(): void {
    this.route.queryParamMap.subscribe((params) => {
      const raw = params.get('to');
      const id = raw ? Number(raw) : NaN;
      this.pendingReceiverId = Number.isFinite(id) && id > 0 ? id : null;
    });
    this.loadData();

    interval(15000).pipe(takeUntilDestroyed(this.destroyRef)).subscribe(() => {
      if (this.auth.user()) {
        this.loadData();
      }
    });
  }

  loadData(): void {
    this.api.getMessages().subscribe({
      next: (items) => {
        const list = Array.isArray(items) ? items : [];
        this.messages.set(list);
        this.applyPendingReceiver();
      },
      error: () => this.messages.set([])
    });

    this.api.getUsers().subscribe({
      next: (items) => {
        const arr = Array.isArray(items) ? items : [];
        const currentEmail = this.auth.user()?.email;
        const role = this.auth.user()?.role;
        const filtered = arr.filter((u) => u.email !== currentEmail);
        this.recipients.set(role === 'CANDIDATE' ? filtered.filter((u) => u.role === 'HR_ADMIN') : filtered);
        const map = new Map<number, string>();
        const byId = new Map<number, User>();
        arr.forEach((u) => {
          map.set(u.id, u.full_name);
          byId.set(u.id, u);
        });
        this.usersMap.set(map);
        this.usersById.set(byId);
      },
      error: () => {
        this.recipients.set([]);
        this.usersMap.set(new Map());
        this.usersById.set(new Map());
        this.applyPendingReceiver();
      }
    });
  }

  private applyPendingReceiver(): void {
    if (!this.pendingReceiverId) return;
    const id = this.pendingReceiverId;
    const myId = this.auth.user()?.id;
    const hasConversation = this.messages().some(
      (m) => (m.sender_id === id && m.receiver_id === myId) || (m.receiver_id === id && m.sender_id === myId)
    );
    if (hasConversation) {
      this.openConversation(id);
    } else {
      this.selectedConversationId.set(null);
      this.form.receiver_id = id;
      this.form.content = '';
    }
    this.pendingReceiverId = null;
  }

  openConversation(otherUserId: number): void {
    this.selectedConversationId.set(otherUserId);
    this.form.receiver_id = otherUserId;
    this.form.content = '';
    this.markThreadAsRead(otherUserId);
  }

  markThreadAsRead(otherUserId: number): void {
    const myId = this.auth.user()?.id;
    if (!myId) return;
    const toMark = this.messages().filter(
      (m) => m.receiver_id === myId && m.sender_id === otherUserId && m.is_read !== true
    );
    toMark.forEach((m) => this.api.markMessageRead(m.id).subscribe());
    if (toMark.length) {
      this.loadData();
    }
  }

  getOtherUserName(userId: number): string {
    return this.usersMap().get(userId) ?? 'Utilisateur';
  }

  isSentByMe(msg: Message): boolean {
    return msg.sender_id === this.auth.user()?.id;
  }

  isUnreadIncoming(msg: Message): boolean {
    return !this.isSentByMe(msg) && msg.receiver_id === this.auth.user()?.id && msg.is_read !== true;
  }

  sendMessage(): void {
    if (!this.form.receiver_id || !this.form.content.trim()) return;
    this.api.sendMessage({
      receiver_id: this.form.receiver_id,
      content: this.form.content.trim()
    }).subscribe({
      next: () => {
        this.form.receiver_id = 0;
        this.form.content = '';
        this.loadData();
      }
    });
  }

  sendReply(): void {
    const sel = this.selectedConversationId();
    if (!sel || !this.form.content.trim()) return;
    this.api.sendMessage({
      receiver_id: sel,
      content: this.form.content.trim()
    }).subscribe({
      next: () => {
        this.form.content = '';
        this.loadData();
      }
    });
  }

  selectRecipient(id: number): void {
    this.form.receiver_id = id;
  }

  avatarOf(user: User): string {
    const src = user.avatar_url || user.avatarUrl || '';
    return this.isValidAvatar(src) ? src : '';
  }

  avatarOfId(userId: number): string {
    const user = this.usersById().get(userId);
    return user ? this.avatarOf(user) : '';
  }

  currentAvatar(): string {
    const src = this.auth.user()?.avatar_url || this.auth.user()?.avatarUrl || '';
    return this.isValidAvatar(src) ? src : '';
  }

  initialsForName(name?: string): string {
    return (name ?? 'U')
      .split(' ')
      .map((part) => part[0])
      .slice(0, 2)
      .join('')
      .toUpperCase();
  }

  initialsFor(user: User): string {
    return (user.full_name ?? user.email ?? 'U')
      .split(' ')
      .map((part) => part[0])
      .slice(0, 2)
      .join('')
      .toUpperCase();
  }

  private isValidAvatar(src: string): boolean {
    if (!src) return false;
    return src.startsWith('data:image') || src.startsWith('http://') || src.startsWith('https://');
  }
}
