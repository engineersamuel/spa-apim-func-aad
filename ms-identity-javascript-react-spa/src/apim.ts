import { graphConfig } from "./authConfig";

/**
 * Attaches a given access token to a MS Graph API call. Returns information about the user
 * @param accessToken
 */
export async function callApim(url, accessToken) {
    const headers = new Headers();
    const bearer = `Bearer ${accessToken}`;

    headers.append("Authorization", bearer);

    const options: RequestInit = {
        method: "GET",
        headers: headers,
        mode: "cors"
    };

    return fetch(url, options)
        .then(response => response.json())
        .catch(error => console.log(error));
}
