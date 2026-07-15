import axios from 'axios';

const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000/v1';

const api = axios.create({
  baseURL: API_URL,
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = localStorage.getItem('admin_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('admin_token');
      localStorage.removeItem('admin_user');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export const adminApi = {
  login: (email: string, password: string) =>
    api.post('/admin/login', { email, password }),

  getDashboard: () => api.get('/admin/dashboard'),

  getAuditLogs: (limit?: number) =>
    api.get('/admin/audit-logs', { params: { limit } }),

  getUsers: (page = 1, limit = 20) =>
    api.get('/admin/users', { params: { page, limit } }),

  getUser: (id: string) => api.get(`/admin/users/${id}`),

  getExercises: (page = 1, limit = 20) =>
    api.get('/admin/exercises', { params: { page, limit } }),

  getSubscriptions: () => api.get('/admin/subscriptions'),

  getNotifications: () => api.get('/notifications'),

  sendNotification: (data: { title: string; body: string; type: string }) =>
    api.post('/notifications/send', data),

  updateUserStatus: (id: string, status: string) =>
    api.patch(`/admin/users/${id}`, { status }),

  deleteExercise: (id: string) =>
    api.delete(`/exercises/${id}`),

  createExercise: (data: any) =>
    api.post('/exercises', data),

  updateExercise: (id: string, data: any) =>
    api.patch(`/exercises/${id}`, data),
};

export default api;
