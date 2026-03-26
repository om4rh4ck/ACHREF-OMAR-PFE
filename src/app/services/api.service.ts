import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { Application, DocumentRequest, Interview, InterviewUpdatePayload, JobOffer, LeaveRequest, Message, NewsItem, NotificationItem, SalaryRequest, Stats, User } from '../models';

@Injectable({ providedIn: 'root' })
export class ApiService {
  private readonly http = inject(HttpClient);

  getPublicJobs(): Observable<JobOffer[]> {
    return this.http.get<JobOffer[]>('/api/public/jobs');
  }

  getVisibleJobs(): Observable<JobOffer[]> {
    return this.http.get<JobOffer[]>('/api/jobs/visible');
  }

  getJobs(): Observable<JobOffer[]> {
    return this.http.get<JobOffer[]>('/api/jobs');
  }

  createJob(payload: Record<string, string | number | null>): Observable<JobOffer> {
    return this.http.post<JobOffer>('/api/jobs', payload);
  }

  updateJob(id: number, payload: Record<string, string | number | null>): Observable<JobOffer> {
    return this.http.put<JobOffer>(`/api/jobs/${id}`, payload);
  }

  deleteJob(id: number): Observable<void> {
    return this.http.delete<void>(`/api/jobs/${id}`);
  }

  applyToJob(jobId: number, payload: Record<string, string>): Observable<Application> {
    return this.http.post<Application>(`/api/jobs/${jobId}/apply`, payload);
  }

  getStats(): Observable<Stats> {
    return this.http.get<Stats>('/api/stats');
  }

  getUsers(): Observable<User[]> {
    return this.http.get<User[]>('/api/users');
  }

  deleteUser(id: number): Observable<void> {
    return this.http.delete<void>(`/api/users/${id}`);
  }

  updateUserRole(id: number, role: string): Observable<User> {
    return this.http.put<User>(`/api/users/${id}/role`, { role });
  }

  updateUser(id: number, payload: { department?: string; position?: string; manager_id?: number | null; salary?: number | null; contract_type?: string | null }): Observable<User> {
    return this.http.put<User>(`/api/users/${id}`, payload);
  }

  getDepartments(): Observable<{ id: number; name: string; description?: string }[]> {
    return this.http.get<{ id: number; name: string; description?: string }[]>('/api/departments');
  }

  createDepartment(payload: { name: string; description?: string }): Observable<{ id: number; name: string; description?: string }> {
    return this.http.post<{ id: number; name: string; description?: string }>('/api/departments', payload);
  }

  getPositions(): Observable<{ id: number; title: string; department?: string }[]> {
    return this.http.get<{ id: number; title: string; department?: string }[]>('/api/positions');
  }

  createPosition(payload: { title: string; department?: string }): Observable<{ id: number; title: string; department?: string }> {
    return this.http.post<{ id: number; title: string; department?: string }>('/api/positions', payload);
  }

  deletePosition(id: number): Observable<void> {
    return this.http.delete<void>(`/api/positions/${id}`);
  }

  getContractTypes(): Observable<{ id: number; name: string; description?: string }[]> {
    return this.http.get<{ id: number; name: string; description?: string }[]>('/api/contract-types');
  }

  createContractType(payload: { name: string; description?: string }): Observable<{ id: number; name: string; description?: string }> {
    return this.http.post<{ id: number; name: string; description?: string }>('/api/contract-types', payload);
  }

  createUser(payload: { email: string; full_name: string; password: string; role: string; department?: string; manager_id?: number | null }): Observable<{ user: User }> {
    return this.http.post<{ user: User }>('/api/auth/admin/create-user', payload);
  }

  getTeam(): Observable<User[]> {
    return this.http.get<User[]>('/api/team');
  }

  getTeamStats(): Observable<{ teamSize: number; pendingLeaves: number; performanceAvg: string; trainingCompletion: string }> {
    return this.http.get<{ teamSize: number; pendingLeaves: number; performanceAvg: string; trainingCompletion: string }>('/api/team/stats');
  }

  getApplications(): Observable<Application[]> {
    return this.http.get<Application[]>('/api/applications');
  }

  updateApplicationStatus(id: number, status: string): Observable<Application> {
    return this.http.put<Application>(`/api/applications/${id}/status`, { status });
  }

  getInterviews(): Observable<Interview[]> {
    return this.http.get<Interview[]>('/api/interviews');
  }

  scheduleInterview(payload: Record<string, string | number>): Observable<Interview> {
    return this.http.post<Interview>('/api/interviews', payload);
  }

  updateInterview(id: number, payload: InterviewUpdatePayload): Observable<Interview> {
    return this.http.put<Interview>(`/api/interviews/${id}`, payload);
  }

  getNews(): Observable<NewsItem[]> {
    return this.http.get<NewsItem[]>('/api/news');
  }

  publishNews(payload: Record<string, string>): Observable<NewsItem> {
    return this.http.post<NewsItem>('/api/news', payload);
  }

  getMessages(): Observable<Message[]> {
    return this.http.get<Message[]>('/api/messages');
  }

  sendMessage(payload: { receiver_id: number; content: string }): Observable<Message> {
    return this.http.post<Message>('/api/messages', payload);
  }

  markMessageRead(id: number): Observable<{ ok: boolean }> {
    return this.http.put<{ ok: boolean }>(`/api/messages/${id}/read`, {});
  }

  getNotifications(): Observable<NotificationItem[]> {
    return this.http.get<NotificationItem[]>('/api/notifications');
  }

  createNotification(payload: { user_id: number; message: string; type?: string }): Observable<NotificationItem> {
    return this.http.post<NotificationItem>('/api/notifications', payload);
  }

  markNotificationRead(id: number): Observable<{ ok: boolean }> {
    return this.http.put<{ ok: boolean }>(`/api/notifications/${id}/read`, {});
  }

  updateProfile(payload: Record<string, string>): Observable<{ user: User }> {
    return this.http.put<{ user: User }>('/api/auth/profile', payload);
  }

  createLeave(payload: { type: string; start_date: string; end_date: string; reason: string }): Observable<LeaveRequest> {
    return this.http.post<LeaveRequest>('/api/leaves', payload);
  }

  createLeaveByAdmin(payload: { employee_email: string; type: string; start_date: string; end_date: string; reason: string }): Observable<LeaveRequest> {
    return this.http.post<LeaveRequest>('/api/leaves/admin', payload);
  }

  getMyLeaves(): Observable<LeaveRequest[]> {
    return this.http.get<LeaveRequest[]>('/api/leaves/my');
  }

  getPendingLeaves(): Observable<LeaveRequest[]> {
    return this.http.get<LeaveRequest[]>('/api/leaves/pending');
  }

  updateLeaveStatus(id: number, status: string): Observable<LeaveRequest> {
    return this.http.put<LeaveRequest>(`/api/leaves/${id}/status?status=${status}`, {});
  }

  createDocumentRequest(payload: { type: string; details: string }): Observable<DocumentRequest> {
    return this.http.post<DocumentRequest>('/api/documents', payload);
  }

  createDocumentByAdmin(payload: { employee_email: string; type: string; details: string }): Observable<DocumentRequest> {
    return this.http.post<DocumentRequest>('/api/documents/admin', payload);
  }

  getMyDocuments(): Observable<DocumentRequest[]> {
    return this.http.get<DocumentRequest[]>('/api/documents/my');
  }

  getPendingDocuments(): Observable<DocumentRequest[]> {
    return this.http.get<DocumentRequest[]>('/api/documents/pending');
  }

  updateDocumentStatus(id: number, status: string): Observable<DocumentRequest> {
    return this.http.put<DocumentRequest>(`/api/documents/${id}/status?status=${status}`, {});
  }

  createSalaryRequest(payload: { month: number; year: number; details: string }): Observable<SalaryRequest> {
    return this.http.post<SalaryRequest>('/api/salaries', payload);
  }

  createSalaryByAdmin(payload: { employee_email: string; month: number; year: number; details: string }): Observable<SalaryRequest> {
    return this.http.post<SalaryRequest>('/api/salaries/admin', payload);
  }

  getMySalaries(): Observable<SalaryRequest[]> {
    return this.http.get<SalaryRequest[]>('/api/salaries/my');
  }

  getPendingSalaries(): Observable<SalaryRequest[]> {
    return this.http.get<SalaryRequest[]>('/api/salaries/pending');
  }

  updateSalaryStatus(id: number, status: string): Observable<SalaryRequest> {
    return this.http.put<SalaryRequest>(`/api/salaries/${id}/status?status=${status}`, {});
  }
}
