## Setup EntraID integration with Traefik Hub

### Create Demo Users

1. From Microsoft Entra ID, navitage to <b>Manage</b> and then <b> Users</b>.
2. From <b>New User</b>, select <b>Create New User</b>. 

3. Create <b>ms-admin</b> and <b>ms-support</b> user accounts as shown below: 

   <img width=600 src="../media/az-admin.png">

5. We should have two accounts created.

   ![Users](../media/Users.png)

### Create Demo Groups

1. From Microsoft Entra ID, navitage to <b>Manage</b> and then <b>Groups</b>.
2. Select <b>New Group</b> and create <b>admin</b> and <b>support</b> groups as shown below.   
   >*Ensure to add <b>ms-admin</b> user to <b>admin</b> group under <b> Members</b> section*.   

   >*Ensure to add <b>ms-support</b> user to <b>support</b> group under <b> Members</b> section*. 

   <img width=600 src="../media/admin-group.png">

3. We should have two groups created as shown below

   ![groups](../media/groups.png)

### Create App Registration

1. From Microsoft Entra ID, navitage to <b>Manage</b> and then <b>App Registrations</b>.
2. Select <b>New Registrations</b> and create <b>traefik-workshop</b> app registration as shown below. 

   >*Ensure to change EXTERNAL_IP to your Loadbalancer IP*.     

   <img width=600 src="../media/register-app.png">

### Configure App Registration

#### A. Update Authorization URLs

1. From <b>traefik-workshop</b>, navigate to <b>Manage</b>, <b>Authentication</b>.
2. Under <b>Web</b>, <b>Redirect URIs</b> section, select <b>add URI</b>. Update the list as shown below to include the portal URL, too:

   >*Ensure to change EXTERNAL_IP to your Loadbalancer IP*.   

   <img width=600 src="../media/Authentication.png">

#### B. Expose an API

1. From <b>traefik-workshop</b>, navigate to <b>Manage</b>, <b>Authentication</b>.
2. Select <b>Add</b> for <b>Application ID URI</b> and then select <b>Save</b>.
3. Select <b>Add a scope</b> and fill in the information as shown below to prepare for returning the group information of the users.

   <img width=600 src="../media/expose-api.png">
