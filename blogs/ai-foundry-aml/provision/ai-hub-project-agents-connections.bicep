// Input parameters for the deployment
param location string                               // Azure region where resources will be deployed
param tags object                                   // Resource tags for organization and billing
param aiHubName string                             // Name of the AI Hub workspace
param aiHubFriendlyName string = aiHubName         // Display name for the AI Hub (defaults to aiHubName)
param aiHubDescription string                       // Description of the AI Hub's purpose
param storageAccountId string                       // Resource ID of the storage account to use
param aiServicesId string                          // Resource ID of the Azure AI Services account
param aiServicesTarget string                      // Endpoint URL of the Azure AI Services account
param aiServicesName string                        // Name of the Azure AI Services account
param aiServiceAccountResourceGroupName string      // Resource group containing the AI Services account
param aiServiceAccountSubscriptionId string         // Subscription ID containing the AI Services account
param aiServiceKind string                         // Type of AI service (e.g., 'OpenAI', 'CognitiveServices')
param aiProjectName string                         // Name of the AI project
param capabilityHostName string                    // Name of the capability host for the project
param aiServiceExists bool = true                  // Flag indicating if AI Services account already exists

// Specify that this template deploys at the resource group level
targetScope = 'resourceGroup'

// Reference to an existing Azure AI Services account
// The 'existing' keyword indicates we're referencing a resource that already exists
resource aiServices 'Microsoft.CognitiveServices/accounts@2023-05-01' existing = {
  name: aiServicesName
  scope: resourceGroup(aiServiceAccountSubscriptionId, aiServiceAccountResourceGroupName)
}

// Create the AI Hub workspace
// This is the main container for AI projects and their resources
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-07-01-preview' = {
  name: aiHubName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'  // Enables managed identity for secure access to Azure resources
  }
  properties: {
    friendlyName: aiHubFriendlyName
    description: aiHubDescription
    storageAccount: storageAccountId  // Associates a storage account for the workspace
  }
  kind: 'hub'  // Specifies this is an AI Hub workspace

  // Create a connection to Azure AI Services
  // This enables the AI Hub to use capabilities like GPT models or cognitive services
  resource aiServicesConnection 'connections@2024-07-01-preview' = {
    name: '${aiHubName}-connection-AIServices'
    properties: {
      category: aiServiceKind          // Specifies the type of AI service
      target: aiServicesTarget         // The endpoint URL to connect to
      authType: 'AAD'                  // Uses Azure Active Directory for authentication
      isSharedToAll: true             // Makes the connection available to all projects
      metadata: {
        ApiType: 'Azure'              // Indicates this is an Azure API
        ResourceId: aiServicesId      // Links to the specific AI service resource
        Location: location            // Region where the service is deployed
      }
    }
  }
}

// Create a capability host for the AI project
// Capability hosts manage specific AI capabilities like agents
resource capabilityHost 'capabilityHosts@2024-10-01-preview' = {
  name: '${aiProjectName}-${capabilityHostName}'
  properties: {
    capabilityHostKind: 'Agents'      // Specifies this host will manage AI agents
    aiServicesConnections: [aiServicesConnection]  // Links the AI services connection created above
    // Add other connections as needed
  }
}

// Output values that can be used by other templates or scripts
output aiHubId string = aiHub.id      // Resource ID of the created AI Hub
output aiServicesName string = aiServiceExists ? aiServices.name : aiServicesName  // Name of the AI service
output aiServicesId string = aiServiceExists ? aiServices.id : aiServicesId        // Resource ID of the AI service
output aiServicesTarget string = aiServiceExists ? aiServices.properties.endpoint : aiServicesTarget  // Endpoint URL
output aiServiceAccountResourceGroupName string = aiServiceExists ? aiServiceAccountResourceGroupName : resourceGroup().name
output aiServiceAccountSubscriptionId string = aiServiceExists ? aiServiceAccountSubscriptionId : subscription().subscriptionId
output storageId string = storageAccountId        // ID of the associated storage account
output aiProjectName string = aiProjectName       // Name of the AI project
output aiProjectResourceId string = aiHub.id      // Resource ID of the project (placeholder)
output aiProjectPrincipalId string = aiHub.properties.identity.principalId  // Managed identity ID (placeholder)
output aiProjectWorkspaceId string = 'Replace with actual workspace ID'     // Workspace ID (placeholder)
output projectConnectionString string = 'Replace with actual project connection string'  // Connection string (placeholder)
