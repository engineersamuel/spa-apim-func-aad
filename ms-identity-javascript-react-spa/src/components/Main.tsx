import React from "react";
import { AuthenticatedTemplate, UnauthenticatedTemplate, useMsal } from "@azure/msal-react";
import Profile from "./Profile";

/**
 * If a user is authenticated the Profile component above is rendered. Otherwise a message indicating a user is not authenticated is rendered.
 */
const Main: React.FC = () => {
  return (
    <div className="App">
      <AuthenticatedTemplate>
        <Profile />
      </AuthenticatedTemplate>
      <UnauthenticatedTemplate>
        <h5 className="card-title">Please sign-in to see your profile information.</h5>
      </UnauthenticatedTemplate>
    </div>
  );
};

export default Main;