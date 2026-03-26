export interface User {
  id: number;
  email: string;
  full_name: string;
  role: 'EMPLOYEE' | 'MANAGER' | 'HR_ADMIN' | 'RECRUITER' | 'CANDIDATE';
  department?: string;
  manager_id?: number;
  managerId?: number;
  position?: string;
  experience?: string;
  leave_balance?: number;
  total_hours?: number;
  phone?: string;
  country?: string;
  city?: string;
  diploma?: string;
  avatar_url?: string;
  avatarUrl?: string;
  salary?: number;
  contract_type?: string;
  contractType?: string;
}

export interface JobOffer {
  id: number;
  title: string;
  department: string;
  description: string;
  requirements: string;
  eligibility_criteria?: string;
  status: 'DRAFT' | 'PUBLISHED' | 'CLOSED' | 'FILLED' | string;
  type: 'INTERNAL' | 'EXTERNAL';
  recruiter_id?: number;
  opening_date?: string;
  closing_date: string;
  salary_range: string;
}

export interface Application {
  id: number;
  job_id: number;
  job_title?: string;
  status: string;
  applied_at: string;
  cover_letter: string;
  cv_file?: string;
  cvFile?: string;
  cin_file?: string;
  cinFile?: string;
  diploma_file?: string;
  diplomaFile?: string;
  phone: string;
  city: string;
  country: string;
  full_name: string;
  email: string;
}

export interface Interview {
  id: number;
  application_id: number;
  candidate_name?: string;
  candidate_email?: string;
  candidateEmail?: string;
  job_title?: string;
  date: string;
  score?: number;
  comments?: string;
  status: string;
}

export interface Stats {
  employees: number;
  openJobs: number;
  totalApplications: number;
  departmentStats: { department: string; count: number }[];
  mobilityRate?: string;
  avgRecruitmentTime?: string;
}

export interface NewsItem {
  id: number;
  title: string;
  content: string;
  author_name?: string;
  created_at: string;
}

export interface InterviewUpdatePayload {
  score?: number;
  comments?: string;
  status?: string;
}

export interface Message {
  id: number;
  sender_id: number;
  receiver_id: number;
  content: string;
  created_at: string;
  sender_name?: string;
  is_read?: boolean;
}

export interface NotificationItem {
  id: number;
  userId: number;
  message: string;
  type: string;
  isRead: boolean;
  createdAt: string;
}

export interface LeaveRequest {
  id: number;
  user_id?: number;
  employee_email?: string;
  type: string;
  start_date: string;
  end_date: string;
  reason?: string;
  status: string;
  created_at: string;
}

export interface DocumentRequest {
  id: number;
  user_id?: number;
  employee_email?: string;
  type: string;
  details?: string;
  status: string;
  created_at: string;
}

export interface SalaryRequest {
  id: number;
  user_id?: number;
  employee_email?: string;
  month: number;
  year: number;
  details?: string;
  status: string;
  created_at: string;
}
