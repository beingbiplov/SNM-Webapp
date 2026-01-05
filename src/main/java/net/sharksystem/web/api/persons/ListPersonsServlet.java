package net.sharksystem.web.api.persons;

import java.io.IOException;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.web.peer.PeerRuntime;
import net.sharksystem.pki.SharkPKIComponent;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.asap.persons.PersonValues;
import net.sharksystem.web.peer.PeerRuntimeManager;

import static net.sharksystem.web.api.pki.WebPKIUtils.getIAExplainText;

/**
 * API to list all persons known to the active peer.
 *
 * GET /api/persons
 */
@WebServlet("/api/persons")
public class ListPersonsServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        JsonObject response = new JsonObject();

        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty("msg", "No active peer found");
            write(resp, response);
            return;
        }

        SharkPKIComponent pki = peer.getPkiComponent();
        JsonArray personsArray = new JsonArray();

        try {
            int count = pki.getNumberOfPersons();

            for (int i = 0; i < count; i++) {
                PersonValues pv = pki.getPersonValuesByPosition(i);

                JsonObject personJson = new JsonObject();
                personJson.addProperty("index", i + 1);
                personJson.addProperty("id", pv.getUserID().toString());
                personJson.addProperty("name", pv.getName().toString());
                personJson.addProperty("signingFailureRate", pv.getSigningFailureRate());

                int ia = pki.getIdentityAssurance(pv.getUserID());

                JsonObject iaJson = new JsonObject();
                iaJson.addProperty("value", ia);
                iaJson.addProperty("explanation", getIAExplainText(ia));

                personJson.add("identityAssurance", iaJson);
                personsArray.add(personJson);
            }

            response.addProperty("count", personsArray.size());
            response.add("persons", personsArray);

            resp.setStatus(HttpServletResponse.SC_OK);
            write(resp, response);

        } catch (Exception e) {
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty(
                    "msg",
                    "Failed to list persons: " + e.getMessage()
            );
            write(resp, response);
        }
    }

    private void write(HttpServletResponse resp, JsonObject response)
            throws IOException {
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(response));
    }
}
