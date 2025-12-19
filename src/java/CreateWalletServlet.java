
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/CreateWallet")
public class CreateWalletServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            // 1. Get userId from session 
            HttpSession session = request.getSession();
            Object uidObj = session.getAttribute("userId");

            if (uidObj == null) {
                response.getWriter().println("Error: User is not logged in. Cannot create wallet.");
                return;
            }

            int userId = (int) uidObj;

            // 2. Generate wallet
            Wallet wallet = WalletGenerator.generateNewWallet(userId);

            // 3. Save wallet using WalletCRUD
            WalletCRUD crud = new WalletCRUD();
            boolean inserted = crud.insertWallet(wallet);

            if (inserted) {
                // If success, redirect to wallet UI page
                response.sendRedirect("WalletServlet");
            } else {
                response.getWriter().println("Error: Failed to store wallet in database.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Wallet creation failed: " + e.getMessage());
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doPost(request, response);
    }
}
