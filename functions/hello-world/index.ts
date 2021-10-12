import { AzureFunction, Context, HttpRequest } from "@azure/functions"

const httpTrigger: AzureFunction = async function (context: Context, req: HttpRequest): Promise<void> {
  context.log('HTTP trigger function processed a request.');
  const name = (req.query.name || (req.body && req.body.name));
  const responseMessage = name
    ? { name }
    : { name: 'Unknown! Set a ?name=<name> in the url'};

  context.res = {
    // status: 200, /* Defaults to 200 */
    body: responseMessage,
    headers: {
      'Content-Type': 'application/json'
    }
  };
};

export default httpTrigger;