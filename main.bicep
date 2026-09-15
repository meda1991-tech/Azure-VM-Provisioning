param vmName string = 'vm-prod-01'
param adminUsername string = 'azureadmin'

@secure()
param adminPassword string

resource vnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-prod'
  location: resourceGroup().location

  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }

    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: '${vmName}-nic'
  location: resourceGroup().location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
  name: vmName
  location: resourceGroup().location

  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }

    storageProfile: {
      imageReference: {
        id: '/subscriptions/c8a8d503-3826-4571-922f-84a66e1f23cf/resourceGroups/test_image/providers/Microsoft.Compute/galleries/test_image/images/test_image_definition/versions/1.0.0'
      }
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
