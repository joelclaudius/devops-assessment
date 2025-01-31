import axios from "axios";

const axiosInstance = axios.create({
  // baseURL: "https://betex-international.com/api",
  // baseURL: "http://blogs.kedevs.com/api/",
  baseURL: "frontend-alb-1075174779.us-east-1.elb.amazonaws.com/api",
  headers: {
    "Content-Type": "application/json",
  },
});

// Add request interceptor to include Authorization header
axiosInstance.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem("access_token");
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add response interceptor for handling token refresh
axiosInstance.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    // Check if the error is due to an expired token
    if (
      error.response?.status === 401 &&
      !originalRequest._retry &&
      localStorage.getItem("refresh_token")
    ) {
      originalRequest._retry = true; // Prevent retry loop

      try {
        const refreshToken = localStorage.getItem("refresh_token");

        // Request new access token using the refresh token
        const { data } = await axios.post(
          "http://127.0.0.1:8000/api/refresh/",
          {
            refresh: refreshToken,
          }
        );

        // Store new access token
        localStorage.setItem("access_token", data.access);

        // Update the Authorization header with the new token
        originalRequest.headers.Authorization = `Bearer ${data.access}`;

        // Retry the original request
        return axiosInstance(originalRequest);
      } catch (refreshError) {
        // If refresh token fails, log the user out
        localStorage.removeItem("access_token");
        localStorage.removeItem("refresh_token");
        localStorage.removeItem("user");
        window.location.href = "/login"; // Redirect to login page
      }
    }

    return Promise.reject(error);
  }
);

export default axiosInstance;
