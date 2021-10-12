/*
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License.
 */

import React from "react";
import Navbar from "react-bootstrap/Navbar";

import { useIsAuthenticated } from "@azure/msal-react";
import { SignInButton } from "./SignInButton";
import { SignOutButton } from "./SignOutButton";
import config from '../config.json';

/**
 * Renders the navbar component with a sign-in or sign-out button depending on whether or not a user is authenticated
 * @param props
 */
export const PageLayout: React.FC = (props) => {
  const isAuthenticated = useIsAuthenticated();

  return (
    <>
      <Navbar bg="primary" variant="dark">
        <a className="navbar-brand" href="/">Microsoft Identity Platform</a>
        { isAuthenticated ? <SignOutButton /> : <SignInButton /> }
      </Navbar>
      <h5 className="text-align-center">Welcome to the Microsoft Authentication Library For Javascript - React Quickstart</h5>
      <br />
      <br />
      <p className="text-align-center">
        <div>clientId: {config.clientId}</div>
        <div>authority: {config.authority}</div>
        <div>scopes: {JSON.stringify(config.scopes, null, ' ')}</div>
      </p>
      {props.children}
    </>
  );
};
