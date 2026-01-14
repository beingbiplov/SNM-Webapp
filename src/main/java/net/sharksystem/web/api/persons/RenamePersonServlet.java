package net.sharksystem.web.api.persons;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import jakarta.servlet.http.HttpServlet;
import net.sharksystem.asap.ASAPException;
import net.sharksystem.web.peer.PeerRuntime;
import jakarta.servlet.annotation.WebServlet;
import net.sharksystem.pki.SharkPKIComponent;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import net.sharksystem.asap.persons.PersonValues;
import net.sharksystem.asap.ASAPSecurityException;
import net.sharksystem.web.peer.PeerRuntimeManager;

import java.io.IOException;
import java.util.Set;

/**
 * API to rename a person known to the active peer.
 *
 * POST /api/persons/rename
 *
 * Body parameters:
 * - oldName: current name of the person
 * - newName: new name for the person
 */
@WebServlet("/api/persons/rename")
public class RenamePersonServlet extends HttpServlet {

    private final PeerRuntimeManager manager = PeerRuntimeManager.getInstance();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        JsonObject response = new JsonObject();

        PeerRuntime peer = manager.getActivePeer();
        if (peer == null) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty("error", "no active peer found");
            write(resp, response);
            return;
        }

        JsonObject body = gson.fromJson(req.getReader(), JsonObject.class);
        if (body == null
                || !body.has("oldName")
                || !body.has("newName")) {

            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("error", "required: oldName, newName");
            write(resp, response);
            return;
        }

        String oldName = body.get("oldName").getAsString();
        String newName = body.get("newName").getAsString();

        SharkPKIComponent pki = peer.getPkiComponent();

        try {
            // find person to rename
            Set<PersonValues> persons = pki.getPersonValuesByName(oldName);

            if (persons.size() > 1) {
                resp.setStatus(HttpServletResponse.SC_CONFLICT);
                response.addProperty(
                        "error",
                        "more than one persons found with name " + oldName
                );
                write(resp, response);
                return;
            }

            PersonValues personToRename = persons.iterator().next();

            // check if new name already exists
            try {
                Set<PersonValues> newNamePersons =
                        pki.getPersonValuesByName(newName);

                if (!newNamePersons.isEmpty()) {
                    resp.setStatus(HttpServletResponse.SC_CONFLICT);
                    response.addProperty(
                            "error",
                            "name already taken: " + newName
                    );
                    write(resp, response);
                    return;
                }
            } catch (ASAPException ignored) {
                // name not in use
            }

            // rename + persist
            personToRename.setName(newName);
            pki.saveMemento();

            response.addProperty("status", "ok");
            response.addProperty(
                    "message",
                    "changed name from " + oldName + " to " + newName
            );

            resp.setStatus(HttpServletResponse.SC_OK);
            write(resp, response);

        } catch (ASAPSecurityException e) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.addProperty("error", e.getMessage());
            write(resp, response);
        } catch (ASAPException e) {
            resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
            response.addProperty(
                    "error",
                    "no person found with name " + oldName
            );
            write(resp, response);

        }
    }

    private void write(HttpServletResponse resp, JsonObject json)
            throws IOException {
        resp.setContentType("application/json");
        resp.getWriter().write(gson.toJson(json));
    }
}
