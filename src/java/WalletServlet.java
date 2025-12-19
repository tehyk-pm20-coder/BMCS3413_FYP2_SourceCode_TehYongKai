import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/WalletServlet")
public class WalletServlet extends HttpServlet {

    private final WalletCRUD walletCrud = new WalletCRUD();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        Integer userId = session != null ? (Integer) session.getAttribute("userId") : null;

        if (userId == null) {
            response.sendRedirect("Login.jsp");
            return;
        }

        Wallet wallet = null;
        String message = null;

        try {
            wallet = walletCrud.getWalletByUserId(userId);
            if (wallet == null) {
                message = "No wallet found for your account yet.";
            }
        } catch (Exception e) {
            message = "Unable to load wallet information right now.";
            e.printStackTrace();
        }

        if (wallet != null) {
            request.setAttribute("walletId", wallet.getWalletId());
            request.setAttribute("status", wallet.getStatus());
            request.setAttribute("walletAddress", wallet.getWalletAddress());
            request.setAttribute("balance", wallet.getBalance());
        }

        request.setAttribute("message", message);
        request.getRequestDispatcher("wallet.jsp").forward(request, response);
    }
}
