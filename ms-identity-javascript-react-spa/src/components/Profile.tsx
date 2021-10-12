import React from "react";
import { useMsal } from "@azure/msal-react";
import { loginRequest } from "../authConfig";
import { callMsGraph } from "../graph";
import { callApim } from "../apim";
import Button from "react-bootstrap/Button";
import config from '../config.json';

/**
 * Renders information about the signed-in user or a button to retrieve data about the user
 */
const Profile: React.FC = () => {
  const { instance, accounts } = useMsal();
  const [graphData, setGraphData] = React.useState(null);
  const [accessToken, setAccessToken] = React.useState<string>();
  const [responseCode, setResponseCode] = React.useState(null);

  function RequestProfileData() {
    // Silently acquires an access token which is then attached to a request for MS Graph data
    instance.acquireTokenSilent({
      ...loginRequest,
      account: accounts[0]
    }).then((response) => {
      callMsGraph(response.accessToken).then(response => setGraphData(response));
    });
  }

  function CallAPIM() {
    // Silently acquires an access token which is then attached to a request for MS Graph data
    instance.acquireTokenSilent({
      ...loginRequest,
      account: accounts[0]
    }).then((response) => {
      setAccessToken(response.accessToken);
      callApim(`${config.functionHelloWorld}?name=John`, response.accessToken).then(response => setResponseCode(response));
    });
  }

  return (
    <>
      <h5 className="card-title">Welcome {accounts[0].name}</h5>
      <Button variant="secondary" onClick={CallAPIM}>Call API Management</Button>
      <div>Response: {JSON.stringify(responseCode, null, ' ')}</div>
      <textarea rows={20} cols={100} value={`Bearer ${accessToken ? accessToken : '<Call the API above to see the access token>'}`} />
      {/* graphData ?
          <ProfileData graphData={graphData} />
          :
          // <Button variant="secondary" onClick={RequestProfileData}>Request Profile Information</Button>
          <Button variant="secondary" onClick={CallAPIM}>Call APIM</Button>
      */}
    </>
  );
};

export default Profile;