import React, { useState, useContext } from "react";
import axiosInstance from "../services/api";
import { AuthContext } from "../context/AuthContext";
import { useNavigate } from "react-router-dom";
import { toast } from 'react-toastify';

const BlogPostForm = () => {
  const [title, setTitle] = useState("");
  const [content, setContent] = useState("");
  const { isAuthenticated } = useContext(AuthContext); // Access isAuthenticated from AuthContext
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!isAuthenticated) {
      navigate("/login"); // Redirect to login if not authenticated
      return;
    }
    try {
      await axiosInstance.post("/posts/create/", { title, content });
      toast.success("Blog post created successfully!"); // Display success toast
      setTitle("");
      setContent("");
      navigate("/"); // Navigate to the home page after successful post
    } catch (error) {
      console.error("Error creating post:", error);
      toast.error("Failed to create blog post."); // Display error toast
    }
  };

  return (
    <div className="flex items-center justify-center px-4 py-10">
      <div className="bg-gray-50 dark:bg-slate-900 shadow-xl rounded-lg p-6 sm:p-8 max-w-lg w-full">
        <h1 className="text-2xl sm:text-3xl font-bold text-gray-800 dark:text-slate-200 mb-6 text-center">
          Create Blog Post
        </h1>
        <form onSubmit={handleSubmit} className="space-y-5">
          {/* Title Field */}
          <div>
            <label
              htmlFor="title"
              className="block text-sm font-medium text-gray-700 dark:text-slate-300 mb-1"
            >
              Title
            </label>
            <input
              type="text"
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="w-full border border-gray-300 dark:border-slate-700 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-blue-400 dark:bg-slate-700 dark:text-slate-200"
              placeholder="Enter the title"
              required
            />
          </div>

          {/* Content Field */}
          <div>
            <label
              htmlFor="content"
              className="block text-sm font-medium text-gray-700 dark:text-slate-300 mb-1"
            >
              Content
            </label>
            <textarea
              id="content"
              value={content}
              onChange={(e) => setContent(e.target.value)}
              className="w-full border border-gray-300 dark:border-slate-700 rounded-lg px-4 py-2 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:border-blue-400 dark:bg-slate-700 dark:text-slate-200"
              placeholder="Enter the content"
              rows="5"
              required
            ></textarea>
          </div>

          {/* Submit Button */}
          <button
            type="submit"
            className="w-full bg-blue-600 text-white font-medium py-2 px-4 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-400 focus:ring-offset-2 transition dark:focus:ring-offset-slate-800"
          >
            Post
          </button>
        </form>
      </div>
    </div>
  );
};

export default BlogPostForm;
