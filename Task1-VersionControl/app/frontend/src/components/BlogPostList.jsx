import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import api from "../services/api";

const BlogPostList = () => {
  const [posts, setPosts] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchPosts = async () => {
      try {
        const response = await api.get("/posts/");
        setPosts(response.data);
      } catch (error) {
        console.error("Error fetching posts:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchPosts();
  }, []);

  const handleReadMore = (id) => {
    navigate(`/post/${id}`);
  };

  return (
    <div className="bg-gray-50 dark:bg-slate-900 py-10 px-5 flex items-center">
      <div className="max-w-7xl mx-auto">
        <h1 className="text-3xl md:text-5xl font-extrabold text-gray-900 dark:text-gray-100 text-center mb-12">
          Latest Blog Posts
        </h1>
        {loading ? (
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {Array.from({ length: 6 }).map((_, index) => (
              <div
                key={index}
                className="bg-white dark:bg-gray-800 p-8 rounded-lg shadow-md animate-pulse"
              >
                <div className="h-8 bg-gray-300 dark:bg-gray-700 rounded w-4/5 mb-6"></div>
                <div className="h-6 bg-gray-300 dark:bg-gray-700 rounded w-3/4 mb-4"></div>
                <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-5/6"></div>
              </div>
            ))}
          </div>
        ) : (
          <div className="grid gap-8 md:grid-cols-2 lg:grid-cols-3">
            {posts.map((post) => (
              <div
                key={post.id}
                className="bg-white dark:bg-gray-800 p-4 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200"
              >
                <h2 className="text-3xl font-semibold text-gray-800 dark:text-gray-100 mb-2">
                  {post.title.length > 50
                    ? `${post.title.substring(0, 50)}...`
                    : post.title}
                </h2>
                <p className="text-gray-600 dark:text-gray-300 line-clamp-3 mb-2">
                  {post.content.length > 100
                    ? `${post.content.substring(0, 100)}...`
                    : post.content}
                </p>
                <button
                  onClick={() => handleReadMore(post.id)}
                  className="bg-blue-600 dark:bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-700 dark:hover:bg-blue-600 transition duration-200"
                >
                  Read More
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default BlogPostList;
