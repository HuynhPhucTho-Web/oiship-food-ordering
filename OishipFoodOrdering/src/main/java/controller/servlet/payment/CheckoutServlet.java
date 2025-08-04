package controller.servlet.payment;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonObject;
import dao.OrderDAO;
import dao.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.Order;
import model.Customer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import utils.service.payment.PaymentService;
import utils.service.paymentconfig.PayOSConfig;
import vn.payos.PayOS;
import vn.payos.type.CheckoutResponseData;
import vn.payos.type.ItemData;
import vn.payos.type.PaymentData;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

@WebServlet(name = "CheckoutServlet", urlPatterns = {
    "/customer/payment/create-payment-link",
    "/customer/payment/success",
    "/customer/payment/cancel"
})

/**
 * This class handles all payment-related operations in the system.
 *
 * It includes methods for calculating total amounts, applying vouchers,
 * generating payment details, and updating order payment status.
 *
 * This class is used in the customer checkout process and integrates with
 * third-party payment gateways such as PayOS.
 *
 * @author Huynh Phuc Tho
 * @version 1.0
 * @since 2025-07-11
 */
public class CheckoutServlet extends HttpServlet {

    private static final Logger logger = LoggerFactory.getLogger(CheckoutServlet.class);
    private final PayOS payOS = PayOSConfig.getPayOS();
    private final Gson gson = new GsonBuilder().create();
    private final OrderDAO orderDAO = new OrderDAO();

    /**
     * Handles GET requests for three main purposes: - Creating a PayOS payment
     * link - Handling payment success - Handling payment cancellation
     *
     * @param request HttpServletRequest object
     * @param response HttpServletResponse object
     * @throws ServletException If the request could not be handled
     * @throws IOException If an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("email") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String email = (String) session.getAttribute("email");
        Customer customer = new CustomerDAO().getCustomerByEmail(email);
        if (customer == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String servletPath = request.getServletPath();

        try {
            switch (servletPath) {
                /**
                 * Case: User completed payment successfully. Marks the pending
                 * order as paid and forwards to success page.
                 */
                case "/customer/payment/success":
                    Integer paidOrderId = (Integer) session.getAttribute("pendingOrderId");
                    if (paidOrderId != null) {
                        new PaymentService().payOrder(paidOrderId);
                        session.removeAttribute("pendingOrderId");
                    }
                    request.getRequestDispatcher("/WEB-INF/views/customer/success.jsp").forward(request, response);
                    break;

                /**
                 * Case: User cancels the payment process. Cancels the order if
                 * it exists and redirects back to cart.
                 */
                case "/customer/payment/cancel":
                    Integer cancelledOrderId = (Integer) session.getAttribute("pendingOrderId");
                    if (cancelledOrderId != null) {
                        try {
                            boolean cancelled = orderDAO.cancelOrder(cancelledOrderId);
                            if (cancelled) {
                                logger.info("Order #" + cancelledOrderId + " was successfully cancelled.");
                            } else {
                                logger.warn("Failed to cancel order #" + cancelledOrderId + ". It might not be in pending state.");
                            }
                        } catch (SQLException e) {
                            logger.error("Error cancelling order #" + cancelledOrderId, e);
                        } finally {
                            session.removeAttribute("pendingOrderId");
                        }
                    }
                    response.sendRedirect(request.getContextPath() + "/customer/view-cart");
                    break;
                /**
                 * Case: Create a new PayOS payment link for the pending order.
                 * Returns the checkout URL as JSON and redirects the user to
                 * PayOS.
                 */

                case "/customer/payment/create-payment-link":
                    Integer pendingOrderId = (Integer) session.getAttribute("pendingOrderId");

                    if (pendingOrderId == null) {
                        writeJsonResponse(response, buildErrorResponse("No pending order found."));
                        return;
                    }

                    Order order = orderDAO.getOrderById(pendingOrderId);
                    if (order == null) {
                        writeJsonResponse(response, buildErrorResponse("Order not found."));
                        return;
                    }

                    // Always create a new PayOS link
                    BigDecimal amount = order.getAmount();
                    String description = "Payment for OISHIP system";
                    long orderCode = System.currentTimeMillis(); // hoặc dùng UUID.randomUUID().toString()

                    CheckoutResponseData checkoutData = payOS.createPaymentLink(
                            buildPaymentData(amount.intValue(), description, (int) orderCode, getBaseUrl(request))
                    );

                    // Return checkout URL as JSON
                    JsonObject data = new JsonObject();
                    data.addProperty("checkoutUrl", checkoutData.getCheckoutUrl());
                    JsonObject resJson = new JsonObject();
                    resJson.addProperty("error", 0);
                    resJson.addProperty("message", "success");
                    resJson.add("data", data);
                    writeJsonResponse(response, resJson);
                    // Redirect user to PayOS
                    response.sendRedirect(checkoutData.getCheckoutUrl());
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
            }

        } catch (Exception e) {
            e.printStackTrace();
            logger.error("Error in GET: ", e);
            writeJsonResponse(response, buildErrorResponse("An error occurred while processing the payment."));
        }
    }

    /**
     * Handles POST requests. This servlet does not support POST.
     *
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws IOException Always, since POST is not allowed.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        response.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    /**
     * Builds the PaymentData object required to generate a PayOS checkout link.
     *
     * @param price Total payment amount
     * @param description Description for the payment
     * @param orderId Unique order ID
     * @param baseUrl Base URL of the server to return/cancel after payment
     * @return PaymentData object
     */
    private PaymentData buildPaymentData(int price, String description, int orderId, String baseUrl) {
        return PaymentData.builder()
                .orderCode((long) orderId)
                .amount(price)
                .description(description)
                .returnUrl(baseUrl + "/customer/payment/success")
                .cancelUrl(baseUrl + "/customer/payment/cancel")
                .item(ItemData.builder()
                        .name("Your order code: " + orderId)
                        .quantity(1)
                        .price(price)
                        .build())
                .build();
    }

    /**
     * Returns the base URL of the current server. Used to generate return and
     * cancel URLs for PayOS.
     *
     * @param request HttpServletRequest object
     * @return Full base URL (e.g., http://localhost:8080/app)
     */
    private String getBaseUrl(HttpServletRequest request) {
        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int port = request.getServerPort();
        String context = request.getContextPath();
        return scheme + "://" + serverName + (port == 80 || port == 443 ? "" : ":" + port) + context;
    }

    /**
     * Writes a JSON response to the client.
     *
     * @param response HttpServletResponse object
     * @param json JSON object to write
     * @throws IOException If writing to the output stream fails
     */
    private void writeJsonResponse(HttpServletResponse response, JsonObject json) throws IOException {
        response.setContentType("application/json");
        response.getWriter().write(gson.toJson(json));
    }

    /**
     * Builds a standardized error JSON response.
     *
     * @param message Error message to include
     * @return JsonObject with error details
     */
    private JsonObject buildErrorResponse(String message) {
        JsonObject res = new JsonObject();
        res.addProperty("error", -1);
        res.addProperty("message", message);
        res.add("data", null);
        return res;
    }
}
