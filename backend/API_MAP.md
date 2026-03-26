# Front to Backend Mapping (Current state)

## Auth
- POST `/api/auth/login` -> Keycloak token via employee-service adapter
- GET `/api/auth/me` -> current user from JWT
- PUT `/api/auth/profile` -> employee profile update
- POST `/api/auth/register` -> currently returns informative message (registration should be done via Keycloak)

## Employee
- GET `/api/employees/me`
- GET `/api/employees`
- POST `/api/leaves`
- GET `/api/leaves/my`
- GET `/api/leaves/pending` (MANAGER/HR_ADMIN)
- PUT `/api/leaves/{id}/status?status=APPROVED|REJECTED` (MANAGER/HR_ADMIN)

## Recruitment
- GET `/api/public/jobs`
- GET `/api/recruitment/jobs/internal`
- POST `/api/recruitment/jobs` (HR_ADMIN/RECRUITER)
- POST `/api/recruitment/jobs/{jobId}/apply`
- GET `/api/recruitment/applications/my`
- GET `/api/recruitment/applications/pending` (MANAGER/HR_ADMIN/RECRUITER)
- PUT `/api/recruitment/applications/{id}/status?status=...` (MANAGER/HR_ADMIN/RECRUITER)

## Approvals
- POST `/api/approvals` (MANAGER/HR_ADMIN)
- GET `/api/approvals?targetType=LEAVE|APPLICATION`

## Gateway
- Base URL: `http://localhost:8081`
- Keep frontend fetch paths as `/api/...` by adding Vite proxy to `http://localhost:8081`.
