<br/>

<div align="center" style="margin: 30px;">
<a href="https://traefik.io/traefik-hub-api-gateway">
  <img src="../media/hub_api_gw_logo.png"   style="width:250px;" align="center" />
</a>
<br />
</div>
<div align="center">
    <a href="https://traefik.io/traefik-hub-api-gateway/">Website</a> |
    <a href="https://doc.traefik.io/traefik-hub/api-gateway/api-gateway-intro">Documentation</a> 
</div>

# Traefik Hub API Gateway

## Overview:

The Traefik Hub API Gateway combines the world’s most trusted cloud native, fully declarative application proxy with enterprise-grade access control, distributed security, and premium integrations. 

In this module, we will go through the steps on how to perform a seamless upgrade of <b>Traefik Application Proxy</b> to <b>Traefik Hub API Gateway</b> with minimum impact on existing services.  

<br>

___

## Upgrade Traefik Application Proxy to Traefik Hub API Gateway:

1. Traefik Hub API Gateway requires a license key. To obtain a license key, login to <b><a href="https://hub.traefik.io/dashboard">Traefik Hub Dashboard</a></b>           

    username: COMMON-USERNAME                         
    password: COMMON-PASSWORD      

2. Navigate to <b>Gateways</b> and select <b>Create new gateway</b> 

   ![add_gateway](../media/add_gateway.png)      

3. Copy your new gateway token.     

   ![copy_token](../media/copy_token.png)

4. Store the new gateway token as an environment variable in your terminal.      

    ```bash 
    export TRAEFIK_HUB_TOKEN=
    ```
5. Create a secret to store the newly obtain gateway token.    

    ```bash
    kubectl create secret generic traefik-hub-license --namespace traefik --from-literal=token=$TRAEFIK_HUB_TOKEN
    ```
6. Now that the license key is stored under the same namespace as our existing Traefik Application proxy deployment, we can perform an in-place upgrade to <b>Traefik Hub API Gateway</b> using the same Helm chart. 

    ```bash
    helm upgrade traefik -n traefik --wait \
      --reuse-values \
      --set hub.token=traefik-hub-license \
      --set image.registry=ghcr.io \
      --set image.repository=traefik/traefik-hub \
      --set image.tag=v3.3.1 \
       traefik/traefik
   ```

7. Once the Helm upgrade command is executed successfully, you can refresh the Traefik local dashboard and be presented with the new UI. Since <b>Traefik API Gateway</b> is based on <b>Traefik Application Proxy</b>, there is no impact to any of the existing services. 

___

## Secure access to your application

Now that we have <b> Traefik Hub API Gateway</b> running, we can take advantage of some of the enterprise-level middlewares to secure access to our application so only authorized users have access. 

### Secure access with JWT:

The JWT middleware verifies that a valid JWT token is provided in the Authorization header 

To add a JWT verification method to the incoming request for <b>customer-app</b> API application, follow the below steps:

1. Create JWT middleware definition

    ```yaml
   ---
   apiVersion: traefik.io/v1alpha1
   kind: Middleware
   metadata:
       name: jwt-azure
       namespace: apps
   spec:
     plugin:
       jwt:
         jwksUrl: "https://login.microsoftonline.com/common/discovery/v2.0/keys"    
    ```
2. Update <b> customer-app's</b> <b>IngressRoute</b> definition to attach the newly created JWT middleware.

    ```yaml
    ---
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    metadata:
      name: api-ingress-customers
      namespace: apps                                                                     # Namespace where the application is deployed. 
    spec:
      entryPoints:
        - websecure                                                                       # Request is coming on HTTPS (port 443).
      routes:
        - kind: Rule
          match: Host(`api.traefik.EXTERNAL_IP.sslip.io`) && PathPrefix(`/customers`)     # Traefik will be monitoring for this specific URL.
          services:
            - name: customer-app                                                          # The request routed to customer-app service on port 3000.
              port: 3000
          middlewares:                                                                    
            - name: customer-header                                                       # CustomResponse Header.
            - name: jwt-azure  # Add JWT verification 
      tls:
        certResolver: le
    ```

> [!NOTE]     
> :pencil2: *Run below steps in your cluster.*


```bash
kubectl apply -f module-2/manifests/customer-ingress.yaml
```    


3. Any request to <b>customer-app</b> application will fail without a proper token as part of the header. 

   ```bash
   curl -I https://api.traefik.EXTERNAL_IP.sslip.io/customers
   
   HTTP/2 401 
   ```

### Secure access with OIDC

The OpenID Connect Authentication middleware secures your applications by delegating the authentication to an external provider (ex: EntraID) and obtaining the end user's session claims and scopes for authorization purposes.

To authenticate the user, the middleware redirects to the authentication provider. Once the authentication is complete, users are redirected back to the middleware before being authorized to access the upstream application.    

1. We have <b>whoami</b> application running under <b>apps</b> namespace. 


   ```bash
   kubectl -n apps get pod,svc | egrep "NAME|whoami"
   
   NAME                                   READY   STATUS    RESTARTS        AGE
   pod/whoami-697f8c6cbc-qp5nw            1/1     Running   0               68m
   
   NAME                      TYPE           CLUSTER-IP      EXTERNAL-IP        PORT(S)    AGE
   service/whoami            ClusterIP      10.43.142.176   <none>             80/TCP     68m
   ```

2. Create OIDC middleware to redirect the request to EntraID

   ```bash
   ---
   apiVersion: traefik.io/v1alpha1
   kind: Middleware
   metadata:
     name: oidc-whoami
     namespace: apps
   spec:
     plugin:
       oidc:
         issuer: "https://sts.windows.net/AZURE_TENANT_ID/"
         clientID: "AZURE_CLIENT_ID"
         clientSecret: "AZURE_CLIENT_SECRET"
         redirectUrl: "/cback"
   ```

2. Publish the service using <b>ingressroute</b> and attach the OIDC middleware to the route definition.


    ```yaml
    apiVersion: traefik.io/v1alpha1
    kind: IngressRoute
    metadata:
      name: whoami-ingress                      # IngressRoute Name
      namespace: apps                           # Namespace where the backend service is running. 
    spec:
      entryPoints:
        - web                                   # EntryPoint where Traefik is listening on for incoming requests. 
      routes:
        - kind: Rule
          match: Host(`whoami.URL`)             # match the request with this URL
          services:
            - name: whoami                      # Forward the request to backend service
              port: 80                          # Backend service is listening on Port 80.
          middlewares:
            - name: oidc-whoami                 # List of middlewares that the request need to go through.
    ```

> [!NOTE]     
> :pencil2: *Run below steps in your cluster.*
   
   ```bash
   kubectl apply -f module-2/manifests/whoami-ingress.yaml
   ```


   <details><summary>Verification commands</summary>

   ```bash
   # Verify IngressRoute
   
   kubectl -n apps get ingressroute.traefik.io
   
   NAME             AGE
   whoami-ingress   173m
   ```
   ```bash
   kubectl -n apps describe ingressroute.traefik.io
   
   Name:         whoami-ingress
   Namespace:    apps
   Labels:       <none>
   Annotations:  <none>
   API Version:  traefik.io/v1alpha1
   Kind:         IngressRoute
   Metadata:
     Creation Timestamp:  2024-02-29T18:34:03Z
     Generation:          1
     Resource Version:    1230
     UID:                 306f20de-9c84-4a81-9c2b-02e06360c89f
   Spec:
     Entry Points:
       web
     Routes:
       Kind:   Rule
       Match:  Host(`whoami.EXTERNAL_IP.sslip.io`)      # URL the service is exposed on
       Services:
         Name:  whoami
         Port:  80
   Events:      <none>
   ```
   </details>
   </br>

3. The whoami application should be accessible using the URL in the IngressRoute definition. The request will be redirected to EntraID for verification before its routed to the backend service.

    <details><summary>Expected output after successful login</summary>

    ![whoami](../media/whoami.png)
    </details>  


___





## References:

- 

------
:house: [HOME](../README.md) | :arrow_forward: [module-3](../module-3/readme.md)
