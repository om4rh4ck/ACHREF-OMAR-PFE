import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = async () => {
  const auth = inject(AuthService);
  const router = inject(Router);

  if (auth.isAuthenticated()) {
    return true;
  }

  if (auth.token() && !auth.user()) {
    await auth.restoreSession();
    if (auth.isAuthenticated()) {
      return true;
    }
  }

  void router.navigateByUrl('/auth/login');
  return false;
};
