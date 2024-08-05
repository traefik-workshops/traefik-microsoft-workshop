<br/>

<div align="center" style="margin: 30px;">
<a href="https://traefik.io/traefik-hub/">
  <img src="../media/traefik_hub_logo.png"   style="width:250px;" align="center" />
</a>
<br/>
</div>
<div align="center">
    <a href="https://traefik.io/traefik-hub/">Website</a> |
    <a href="https://doc.traefik.io/traefik-hub/">Documentation</a> 
</div>
</br>

# Traefik Hub API Management

## Overview:
Traefik Hub is the industry’s first Kubernetes-native API Management solution for publishing, securing, and managing APIs.

Traefik Hub, purpose-built for K8s environments and GitOps workflows, drastically simplifies and accelerates the API lifecycle management, so organizations experience quick time to value, unleash workforce productivity, and focus on building great applications.

## Upgrade API Gateway to API Management: 

Upgrading <b>Traefik Hub API Gateway</b> deployment to <b>API Management</b> has never been easier. The license key will need to be updated to include the API Management feature. Then, <b>API Management</b> feature will need to be enabled using below command:

> [!NOTE]     
> :pencil2: *Follow the steps below to enable API Management features*.

```bash
helm upgrade traefik -n traefik --wait \
  --reuse-values \
  --set hub.apimanagement.enabled=true \
   traefik/traefik
```

## Manage an App with APIM:

To manage an application using API Management services, we will need to do the following:

1. Create an API object for Hub APIM service to manage.
2. Create an API Access object to control which group has access to this API.
3. Update the Ingress definition for the application to bind it to the newly created API. 

Let us promote <b>customer-app</b> API application to be managed by API Management services. 

1. Create an API object for <b>customer-app</b>.

   ```bash
   ---
   apiVersion: hub.traefik.io/v1alpha1
   kind: API                        # API Object
   metadata:
     name: customer-api             # Name of the object         
     namespace: apps                # Namespace where the app is deployed
     labels:
       area: customer               # Labels for easier referencing
       module: crm
   spec:
     openApiSpec:
       path: /openapi.yaml           # Path to OAS (OpenAPISpec)file
   ```
2. Create an API Access object to control access to this API. 

    ```bash
    ---
    apiVersion: hub.traefik.io/v1alpha1
    kind: APIAccess                         # API Access Object
    metadata:
      name: admin-access                    # Name of API Access
      namespace: apps                       # Namespace where App is deployed
    spec:
      groups:
        - admin                             # Admin group has access to the APIs matched under API selector section.
      apiSelector:
        matchExpressions:
          - key: area                       # Match any API with label that has "area" set as a key value. 
            operator: Exists 
    ```

3. Promote existing <b>IngressRoute</b> to be managed by <b>APIM</b>.

   ```bash
   ---
   apiVersion: traefik.io/v1alpha1
   kind: IngressRoute
   metadata:
     name: api-ingress-customers
     namespace: apps
     annotations:                                      # Add API annotation to enable APIM
       hub.traefik.io/api: customer-api                # API object that the ingressroute needs to bind to.
   spec:
     entryPoints:
       - websecure
     routes:
       - kind: Rule
         match: Host(`api.traefik.EXTERNAL_IP.sslip.io`) && PathPrefix(`/customers`)
         services:
           - name: customer-app
             port: 3000
     tls:
       certResolver: le
   ```

> [!NOTE]     
> :pencil2: *Follow the steps below to promote customer-api to be managed by APIM*.

```bash
kubectl apply -f module-3/manifests/customer-ingress-api.yaml
```



## References

- Deploy APIs with CRDs.  
https://doc.traefik.io/traefik-hub/tutorials/deploy-apis-from-crds/
- API Versioning with Traefik Hub: Smooth Transitions, Seamless Innovation.  
https://traefik.io/blog/api-versioning-with-traefik-hub/
- API Collections.  
https://doc.traefik.io/traefik-hub/tutorials/api-collections/
- API Access policies.   
https://doc.traefik.io/traefik-hub/reference/crds/#apiaccess
- API Gateway.   
https://doc.traefik.io/traefik-hub/reference/crds/#apigateway
- API Portal.    
https://doc.traefik.io/traefik-hub/reference/crds/#apiportal

</br>

------
:house: [HOME](../README.md) | :arrow_forward: [module-4](../module-4/readme.md)
