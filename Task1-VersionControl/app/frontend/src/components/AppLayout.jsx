import React, { useState, useEffect, useContext } from "react";
import { Link, Outlet, useOutlet, useNavigate } from "react-router-dom";
import {
  SunIcon,
  HomeIcon,
  DocumentAddIcon,
  LoginIcon,
  UserAddIcon,
  MoonIcon,
  MenuIcon,
  XIcon,
} from "@heroicons/react/solid";

import { AuthContext } from "../context/AuthContext";

const AppLayout = () => {
  const [darkMode, setDarkMode] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const outlet = useOutlet();
  const navigate = useNavigate();
  const { isAuthenticated, logout } = useContext(AuthContext);

  // Sync darkMode with local storage
  useEffect(() => {
    const savedDarkMode = localStorage.getItem("darkMode") === "true";
    setDarkMode(savedDarkMode);
    document.documentElement.classList.toggle("dark", savedDarkMode);
    document.body.classList.toggle("dark", savedDarkMode);
  }, []);

  const toggleTheme = () => {
    const newDarkMode = !darkMode;
    setDarkMode(newDarkMode);
    document.documentElement.classList.toggle("dark", newDarkMode);
    document.body.classList.toggle("dark", newDarkMode);
    localStorage.setItem("darkMode", newDarkMode);
  };

  const toggleMenu = () => setMenuOpen(!menuOpen);

  const outletTitle = outlet?.props?.children
    ? outlet.props.children.props.children[0]?.props?.children || "Blogs"
    : "Blogs";

  return (
    <div
      className={`${
        darkMode ? "dark" : ""
      } flex flex-col md:flex-row h-screen bg-gray-50 dark:bg-slate-900`}
    >
      {/* Sidebar for medium and large screens */}
      <aside className="hidden md:flex md:flex-col bg-gradient-to-br from-blue-600 to-indigo-700 dark:bg-gradient-to-br dark:from-slate-800 dark:to-slate-900 w-64 h-screen shadow-lg p-6 overflow-y-auto">
        <h2 className="text-2xl font-bold text-white dark:text-slate-200 mb-8">
          keDevs
        </h2>
        <nav className="space-y-4">
          {isAuthenticated ? (
            <>
              <Link
                to="/"
                className={`block ${
                  window.location.pathname === "/" ? "bg-blue-700 dark:bg-slate-700" : ""
                } text-white dark:text-slate-300 hover:bg-blue-700 dark:hover:bg-slate-700 rounded-md px-4 py-2 transition flex items-center space-x-2`}
              >
                <HomeIcon className="h-5 w-5" />
                <span>View Blogs</span>
              </Link>
              <Link
                to="/create"
                className={`block ${
                  window.location.pathname === "/create" ? "bg-blue-700 dark:bg-slate-700" : ""
                } text-white dark:text-slate-300 hover:bg-blue-700 dark:hover:bg-slate-700 rounded-md px-4 py-2 transition flex items-center space-x-2`}
              >
                <DocumentAddIcon className="h-5 w-5" />
                <span>Create Blog</span>
              </Link>
              <button
                onClick={() => {
                  logout();
                  navigate("/");
                }}
                className="block text-white dark:text-slate-300 hover:bg-blue-700 dark:hover:bg-slate-700 rounded-md px-4 py-2 transition flex items-center space-x-2 w-full text-left"
              >
                <LoginIcon className="h-5 w-5" />
                <span>Logout</span>
              </button>
            </>
          ) : (
            <>
              <Link
                to="/"
                className={`block ${
                  window.location.pathname === "/" ? "bg-blue-700 dark:bg-slate-700" : ""
                } text-white dark:text-slate-300 hover:bg-blue-700 dark:hover:bg-slate-700 rounded-md px-4 py-2 transition flex items-center space-x-2`}
              >
                <HomeIcon className="h-5 w-5" />
                <span>View Blogs</span>
              </Link>
              <Link
                to="/create"
                className={`block ${
                  window.location.pathname === "/create" ? "bg-blue-700 dark:bg-slate-700" : ""
                } text-white dark:text-slate-300 hover:bg-blue-700 dark:hover:bg-slate-700 rounded-md px-4 py-2 transition flex items-center space-x-2`}
              >
                <DocumentAddIcon className="h-5 w-5" />
                <span>Create Blog</span>
              </Link>
              <Link
                to="/login"
                className={`block ${
                  window.location.pathname === "/login" ? "bg-blue-700 dark:bg-slate-700" : ""
                } text-white dark:text-slate-300 hover:bg-blue-700 dark:hover:bg-slate-700 rounded-md px-4 py-2 transition flex items-center space-x-2`}
              >
                <LoginIcon className="h-5 w-5" />
                <span>Login</span>
              </Link>
              <Link
                to="/signup"
                className={`block ${
                  window.location.pathname === "/signup" ? "bg-blue-700 dark:bg-slate-700" : ""
                } text-white dark:text-slate-300 hover:bg-blue-700 dark:hover:bg-slate-700 rounded-md px-4 py-2 transition flex items-center space-x-2`}
              >
                <UserAddIcon className="h-5 w-5" />
                <span>Signup</span>
              </Link>
            </>
          )}
        </nav>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col h-screen overflow-y-auto">
        {/* Header */}
        <header className="bg-gradient-to-r from-blue-600 to-indigo-700 dark:bg-gradient-to-r dark:from-slate-800 dark:to-slate-900 shadow-md">
          <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-4 flex justify-between items-center">
            <h1 className="text-2xl font-bold text-white dark:text-slate-200">
              <Link to="/">{outletTitle}</Link>
            </h1>
            <div className="flex items-center space-x-4">
              <button
                onClick={toggleTheme}
                className="flex items-center justify-center w-10 h-10 bg-white text-gray-800 rounded-full shadow-md hover:bg-gray-100 dark:bg-slate-700 dark:text-slate-300 dark:hover:bg-slate-600 transition duration-200"
                aria-label="Toggle Theme"
              >
                {darkMode ? (
                  <SunIcon className="h-5 w-5" />
                ) : (
                  <MoonIcon className="h-5 w-5" />
                )}
              </button>
              <button
                onClick={toggleMenu}
                className="md:hidden flex items-center justify-center w-10 h-10 bg-white text-gray-800 rounded-full shadow-md hover:bg-gray-100 dark:bg-slate-700 dark:text-slate-300 dark:hover:bg-slate-600 transition duration-200"
                aria-label="Toggle Menu"
              >
                {menuOpen ? <XIcon className="h-5 w-5" /> : <MenuIcon className="h-5 w-5" />}
              </button>
            </div>
          </div>
        </header>

        {/* Content Area */}
        <main className="flex-1 container mx-auto px-4 sm:px-6 lg:px-8 bg-gray-50 dark:bg-slate-800 transition-all duration-300 overflow-y-auto">
          <Outlet />
        </main>

        {/* Footer */}
        <footer className="bg-gray-100 dark:bg-slate-900 py-6 transition-all duration-300">
          <div className="container mx-auto text-center text-gray-600 dark:text-slate-400 text-sm">
            © {new Date().getFullYear()} keDevs Blog. All rights reserved.
          </div>
        </footer>
      </div>

      {/* Mobile Menu */}
      {menuOpen && (
        <div className="absolute top-0 left-0 w-full h-screen bg-gray-50 dark:bg-slate-800 flex flex-col justify-center items-center space-y-6 md:hidden z-50 overflow-y-auto">
          <button
            onClick={toggleMenu}
            className="absolute top-5 right-5 w-10 h-10 bg-white text-gray-800 rounded-full shadow-md hover:bg-gray-100 dark:bg-slate-700 dark:text-slate-300 dark:hover:bg-slate-600 transition duration-200"
            aria-label="Close Menu"
          >
            <XIcon className="h-5 w-5" />
          </button>
          {isAuthenticated ? (
            <>
              <Link
                to="/"
                onClick={toggleMenu}
                className="text-gray-800 dark:text-slate-300 text-lg hover:text-gray-600 dark:hover:text-slate-400 transition duration-200"
              >
                View Blogs
              </Link>
              <Link
                to="/create"
                onClick={toggleMenu}
                className="text-gray-800 dark:text-slate-300 text-lg hover:text-gray-600 dark:hover:text-slate-400 transition duration-200"
              >
                Create Blog
              </Link>
              <button
                onClick={() => {
                  logout();
                  navigate("/");
                }}
                className="text-gray-800 dark:text-slate-300 text-lg hover:text-gray-600 dark:hover:text-slate-400 transition duration-200"
              >
                Logout
              </button>
            </>
          ) : (
            <>
              <Link
                to="/"
                onClick={toggleMenu}
                className="text-gray-800 dark:text-slate-300 text-lg hover:text-gray-600 dark:hover:text-slate-400 transition duration-200"
              >
                View Blogs
              </Link>
              <Link
                to="/create"
                onClick={toggleMenu}
                className="text-gray-800 dark:text-slate-300 text-lg hover:text-gray-600 dark:hover:text-slate-400 transition duration-200"
              >
                Create Blog
              </Link>
              <Link
                to="/login"
                onClick={toggleMenu}
                className="text-gray-800 dark:text-slate-300 text-lg hover:text-gray-600 dark:hover:text-slate-400 transition duration-200"
              >
                Login
              </Link>
              <Link
                to="/signup"
                onClick={toggleMenu}
                className="text-gray-800 dark:text-slate-300 text-lg hover:text-gray-600 dark:hover:text-slate-400 transition duration-200"
              >
                Signup
              </Link>
            </>
          )}
        </div>
      )}
    </div>
  );
};

export default AppLayout;
