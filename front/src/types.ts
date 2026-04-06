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

export interface LeaveRequest {
  id: number;
  user_id: number;
  user_name?: string;
  type: string;
  start_date: string;
  end_date: string;
  reason: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  created_at: string;
}

export interface DocumentRequest {
  id: number;
  user_id: number;
  type: string;
  details?: string;
  file_data?: string;
  file_name?: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  created_at: string;
}

export interface SalaryRequest {
  id: number;
  user_id: number;
  employee_email?: string;
  month: number;
  year: number;
  details?: string;
  file_data?: string;
  file_name?: string;
  status: 'PENDING' | 'APPROVED' | 'REJECTED';
  created_at: string;
}

export interface Message {
  id: number;
  sender_id: number;
  receiver_id: number;
  sender_name?: string;
  receiver_name?: string;
  content: string;
  created_at: string;
}

export interface News {
  id: number;
  title: string;
  content: string;
  author_id: number;
  author_name?: string;
  created_at: string;
}

export interface Employee {
  id: number;
  full_name: string;
  email: string;
  department: string;
  position: string;
  status: 'ACTIVE' | 'INACTIVE';
  join_date: string;
  salary: number;
}

export interface JobOffer {
  id: number;
  title: string;
  department: string;
  description: string;
  requirements: string;
  eligibility_criteria?: string;
  status: 'DRAFT' | 'PUBLISHED' | 'CLOSED' | 'FILLED';
  type: 'INTERNAL' | 'EXTERNAL';
  recruiter_id?: number;
  created_at: string;
  closing_date: string;
  salary_range: string;
}

export interface Application {
  id: number;
  job_id: number;
  job_title?: string;
  user_id: number;
  status: 'PENDING' | 'PRE_SELECTED' | 'INTERVIEW_SCHEDULED' | 'RETAINED' | 'WAITING_LIST' | 'REJECTED';
  applied_at: string;
  cover_letter: string;
  cv_file?: string;
  diploma_file?: string;
  cin_file?: string;
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
  job_title?: string;
  date: string;
  evaluator_id: number;
  score?: number;
  comments?: string;
  status: 'SCHEDULED' | 'COMPLETED' | 'CANCELLED';
}

export interface Notification {
  id: number;
  user_id: number;
  message: string;
  type: string;
  is_read: boolean;
  created_at: string;
}

export interface Stats {
  employees: number;
  openJobs: number;
  totalApplications: number;
  departmentStats: { department: string; count: number }[];
  mobilityRate?: string;
  avgRecruitmentTime?: string;
}

export interface LunchMenu {
  id: number;
  date: string;
  dishes: string; // JSON string of dishes
  status: 'ACTIVE' | 'INACTIVE';
}

export interface LunchBooking {
  id: number;
  user_id: number;
  user_name?: string;
  menu_id: number;
  booking_date: string;
  status: 'CONFIRMED' | 'CANCELLED';
}
