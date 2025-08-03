package controller.customer;

import dao.AccountDAO;
import dao.CustomerProfileDAO;
import dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Customer;
import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;
import model.Account;
import model.Notification;

@WebServlet(name = "EditProfileCustomerServlet", urlPatterns = {"/customer/profile/edit-profile"})
public class EditProfileCustomerServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(EditProfileCustomerServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Check if the session exists and the user is logged in as a customer
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Load all necessary data
        loadPageData(request, response, session);
        
        String email = (String) session.getAttribute("email");
        if (email != null) {
            CustomerProfileDAO cus = new CustomerProfileDAO();
            Customer customer = cus.getCustomerByEmail(email);
            request.setAttribute("customer", customer);
            request.getRequestDispatcher("/WEB-INF/views/customer/customer_edit_profile.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    /**
     * Fallback method to ensure minimum required data for JSP
     */
    private void ensureMinimumPageData(HttpServletRequest request, HttpSession session) {
        // Ensure notifications is never null
        if (request.getAttribute("notifications") == null) {
            request.setAttribute("notifications", new java.util.ArrayList<>());
        }
        
        // Ensure userName is set from session if not already set
        if (request.getAttribute("userName") == null) {
            String sessionUserName = (String) session.getAttribute("userName");
            if (sessionUserName != null) {
                request.setAttribute("userName", sessionUserName);
            } else {
                request.setAttribute("userName", "User");
            }
        }
        
        // Ensure customer object exists with form data if original load failed
        if (request.getAttribute("customer") == null) {
            String email = (String) session.getAttribute("email");
            String newName = request.getParameter("fullName");
            String newPhone = request.getParameter("phone");
            String newAddress = request.getParameter("address");
            
            if (newName != null || newPhone != null || newAddress != null) {
                try {
                    // Create a temporary customer object with form data
                    Customer tempCustomer = new Customer();
                    
                    // Set values safely with validation
                    if (newName != null && !newName.trim().isEmpty()) {
                        tempCustomer.setFullName(newName.trim());
                    }
                    if (newPhone != null && !newPhone.trim().isEmpty()) {
                        tempCustomer.setPhone(newPhone.trim());
                    }
                    if (newAddress != null && !newAddress.trim().isEmpty()) {
                        tempCustomer.setAddress(newAddress.trim());
                    }
                    if (email != null && !email.trim().isEmpty()) {
                        tempCustomer.setEmail(email.trim());
                    }
                    
                    request.setAttribute("customer", tempCustomer);
                    LOGGER.info("Created temporary customer object with form data");
                } catch (IllegalArgumentException e) {
                    LOGGER.warning("Invalid form data for temporary customer: " + e.getMessage());
                    // Create empty customer object if validation fails
                    request.setAttribute("customer", new Customer());
                }
            } else {
                // Create empty customer object if no form data
                request.setAttribute("customer", new Customer());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Check session first
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userId") == null || !"customer".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String email = (String) session.getAttribute("email");
        String newName = request.getParameter("fullName");
        String newPhone = request.getParameter("phone");
        String newAddress = request.getParameter("address");

        // Always load page data first to ensure we have basic info
        loadPageData(request, response, session);

        // Always try to load customer info, regardless of validation
        CustomerProfileDAO cus = new CustomerProfileDAO();
        Customer customer = null;
        if (email != null) {
            customer = cus.getCustomerByEmail(email);
            request.setAttribute("customer", customer);
        }

        if (email != null
                && newName != null && !newName.trim().isEmpty()
                && newPhone != null && !newPhone.trim().isEmpty()
                && newAddress != null && !newAddress.trim().isEmpty()) {

            // Validate input lengths before processing
            try {
                if (newName.trim().length() > 255) {
                    throw new IllegalArgumentException("Full name must not exceed 255 characters");
                }
                if (newPhone.trim().length() > 15) {
                    throw new IllegalArgumentException("Phone must not exceed 15 characters");
                }
                if (newAddress.trim().length() > 255) {
                    throw new IllegalArgumentException("Address must not exceed 255 characters");
                }
                
                boolean success = cus.editCustomerInfoByEmail(email, newName.trim(), newPhone.trim(), newAddress.trim());

                if (success) {
                    session.setAttribute("userName", newName.trim());
                    request.setAttribute("message", "Profile updated successfully.");
                    
                    // Reload customer information after successful update
                    customer = cus.getCustomerByEmail(email);
                    if (customer != null) {
                        request.setAttribute("customer", customer);
                    } else {
                        // If reload fails, create customer with updated data
                        Customer updatedCustomer = new Customer();
                        updatedCustomer.setFullName(newName.trim());
                        updatedCustomer.setPhone(newPhone.trim());
                        updatedCustomer.setAddress(newAddress.trim());
                        updatedCustomer.setEmail(email);
                        request.setAttribute("customer", updatedCustomer);
                    }
                    
                    // Also update account info in request attributes
                    AccountDAO accountDAO = new AccountDAO();
                    Account account = accountDAO.findByEmail(email);
                    if (account != null) {
                        request.setAttribute("account", account);
                        request.setAttribute("userName", account.getFullName());
                    }
                } else {
                    request.setAttribute("error", "Failed to update profile.");
                }
            } catch (IllegalArgumentException e) {
                request.setAttribute("error", "Validation error: " + e.getMessage());
                LOGGER.warning("Validation error during profile update: " + e.getMessage());
            }
        } else {
            request.setAttribute("error", "All fields are required.");
        }

        // Ensure we have minimum required data for JSP rendering
        ensureMinimumPageData(request, session);
        
        request.getRequestDispatcher("/WEB-INF/views/customer/customer_edit_profile.jsp").forward(request, response);
    }

    /**
     * Helper method to load all necessary data for the page
     */
    private void loadPageData(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        try {
            // Get account information using email stored in session
            String email = (String) session.getAttribute("email");
            if (email != null) {
                AccountDAO accountDAO = new AccountDAO();
                Account account = accountDAO.findByEmail(email);
                if (account != null) {
                    request.setAttribute("account", account);
                    request.setAttribute("userName", account.getFullName());
                    
                    // Get notifications using account ID
                    int userId = account.getAccountID();
                    NotificationDAO notificationDAO = new NotificationDAO();
                    List<Notification> notifications = notificationDAO.getUnreadNotificationsByCustomer(userId);
                    request.setAttribute("notifications", notifications);
                    
                } else {
                    request.setAttribute("error", "Account not found.");
                    // Set empty notifications list if account not found
                    request.setAttribute("notifications", new java.util.ArrayList<>());
                }
            } else {
                // Set empty notifications list if no email
                request.setAttribute("notifications", new java.util.ArrayList<>());
            }

            // Refresh remember_me cookie if present
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("email".equals(cookie.getName())) {
                        Cookie emailCookie = new Cookie("email", cookie.getValue());
                        emailCookie.setMaxAge(30 * 24 * 60 * 60);
                        emailCookie.setPath(request.getContextPath());
                        response.addCookie(emailCookie);
                        break;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Set default values when error occurs
            request.setAttribute("error", "Error loading page data: " + e.getMessage());
            request.setAttribute("notifications", new java.util.ArrayList<>());
            
            // Try to set at least the userName from session if available
            String sessionUserName = (String) session.getAttribute("userName");
            if (sessionUserName != null) {
                request.setAttribute("userName", sessionUserName);
            }
        }
    }
}