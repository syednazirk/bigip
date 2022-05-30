@description('REQUIRED - A prefix that will be used to name template resources. Because some resources require globally unique names, we recommend using a unique value.')
param uniqueString string

@description('Valid values include \'None\', or an external load balancer name. A value of \'None\' will not create external load balancer. Specifying a name creates a external load balancer with the name specified.')
param externalLoadBalancerName string = 'None'

@description('Valid values include \'None\', or an internal load balancer name. A value of \'None\' will not create internal load balancer. Specifying a name creates a internal load balancer with the name specified.')
param internalLoadBalancerName string = 'None'

@description('Enter subnet id to use for frontend internal load balancer configuration. If you specified None for provision internal load balancer, this setting has no effect.')
param internalSubnetId string = ''

@description('Valid values include valid tcp ports. Enter an array of ports your applications use. Example: \'[80,443,445]\'')
param loadBalancerRulePorts array = [
  '80'
  '443'
]

@description('Valid values include an array containing network security rule property objects, or an empty array. A non-empty array value creates a security group and inbound rules using the destinationPortRanges and sourceAddressPrefix values provided for each object.')
param nsg0 array = [
  {
    destinationPortRanges: [
      '22'
      '8443'
    ]
    sourceAddressPrefix: ''
    protocol: 'Tcp'
  }
  {
    destinationPortRanges: [
      '80'
      '443'
    ]
    sourceAddressPrefix: ''
    protocol: 'Tcp'
  }
]

@description('Valid values include an array containing network security rule property objects, or an empty array. A non-empty array value creates a security group and inbound rules using the destinationPortRanges and sourceAddressPrefix values provided for each object.')
param nsg1 array = [
  {
    destinationPortRanges: [
      '80'
      '443'
    ]
    sourceAddressPrefix: ''
    protocol: 'Tcp'
  }
]

@description('Valid values include an array containing network security rule property objects, or an empty array. A non-empty array value creates a security group and inbound rules using the destinationPortRanges and sourceAddressPrefix values provided for each object.')
param nsg2 array = [
  {
    destinationPortRanges: [
      '80'
      '443'
    ]
    sourceAddressPrefix: ''
    protocol: 'Tcp'
  }
]

@description('Valid values include an array containing network security rule property objects, or an empty array. A non-empty array value creates a security group and inbound rules using the destinationPortRanges and sourceAddressPrefix values provided for each object.')
param nsg3 array = []

@description('Valid values include an array containing network security rule property objects, or an empty array. A non-empty array value creates a security group and inbound rules using the destinationPortRanges and sourceAddressPrefix values provided for each object.')
param nsg4 array = []

@description('Enter the number of public external ip address to create. At least one is required to build ELB.')
@allowed([
  0
  1
  2
  3
  4
  5
  6
  7
  8
  9
  10
])
param numberPublicExternalIpAddresses int = 1

@description('Enter the number of public mgmt ip addresses to create.')
@allowed([
  0
  1
  2
  3
  4
  5
  6
  7
  8
  9
  10
])
param numberPublicMgmtIpAddresses int = 0

@description('Default key/value resource tags will be added to the resources in this deployment, if you would like the values to be unique adjust them as needed for each key.')
param tagValues object = {
  application: 'APP'
  cost: 'COST'
  environment: 'ENV'
  group: 'GROUP'
  owner: 'OWNER'
}
param location string = resourceGroup().location

var appLoadBalancerFrontEnd = ((numberPublicMgmtIpAddresses == 0) ? constructFrontEndIPConfigID : union(constructFrontEndIPConfigID, mgmtLoadBalancerFrontEnd))
var uniqueString_var = toLower(uniqueString)
var emptyArray = []
var inboundNatPoolsArray = [
  {
    name: 'sshnatpool'
    properties: {
      backendPort: 22
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', externalLoadBalancerName, 'loadBalancerMgmtFrontEnd')
      }
      frontendPortRangeEnd: 50100
      frontendPortRangeStart: 50001
      protocol: 'Tcp'
    }
  }
  {
    name: 'mgmtnatpool'
    properties: {
      backendPort: 8443
      frontendIPConfiguration: {
        id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', externalLoadBalancerName, 'loadBalancerMgmtFrontEnd')
      }
      frontendPortRangeEnd: 50200
      frontendPortRangeStart: 50101
      protocol: 'Tcp'
    }
  }
]
var loadBalancerBackEnd = [
  {
    name: 'loadBalancerBackEnd'
  }
]
var loadBalancerBackEndArray = ((numberPublicMgmtIpAddresses == 0) ? loadBalancerBackEnd : union(loadBalancerBackEnd, loadBalancerMgmtBackEnd))
var loadBalancerMgmtBackEnd = [
  {
    name: 'loadBalancerMgmtBackEnd'
  }
]
var loadBalancerRulePortsLength = length(loadBalancerRulePorts)
var loadBalancingProbesArray = constructLoadBalancerProbes
var loadBalancingRulesArray = constructLoadBalancerRule
var loadBalancingProbesArrayInternal = constructLoadBalancerProbesInternal
var loadBalancingRulesArrayInternal = constructLoadBalancerRuleInternal
var mgmtLoadBalancerFrontEnd = [
  {
    name: 'loadBalancerMgmtFrontEnd'
    properties: {
      publicIPAddress: {
        id: resourceId('Microsoft.Network/publicIPAddresses', '${uniqueString_var}-mgmt-pip0')
      }
    }
  }
]
var nsg0Array = constructNsg0Array
var nsg0Id = ((nsg0Length > 0) ? [
  nsg0Name.id
] : emptyArray)
var nsg0Length = length(nsg0)
var nsg0Name_var = '${uniqueString_var}-nsg0'
var nsg1Array = constructNsg1Array
var nsg1Id = ((nsg1Length > 0) ? [
  nsg1Name.id
] : emptyArray)
var nsg1Length = length(nsg1)
var nsg1Name_var = '${uniqueString_var}-nsg1'
var nsg2Array = constructNsg2Array
var nsg2Id = ((nsg2Length > 0) ? [
  nsg2Name.id
] : emptyArray)
var nsg2Length = length(nsg2)
var nsg2Name_var = '${uniqueString_var}-nsg2'
var nsg3Array = constructNsg3Array
var nsg3Id = ((nsg3Length > 0) ? [
  nsg3Name.id
] : emptyArray)
var nsg3Length = length(nsg3)
var nsg3Name_var = '${uniqueString_var}-nsg3'
var nsg4Array = constructNsg4Array
var nsg4Id = ((nsg4Length > 0) ? [
  nsg4Name.id
] : emptyArray)
var nsg4Length = length(nsg4)
var nsg4Name_var = '${uniqueString_var}-nsg4'
var outboundNsgRule = [
  {
    name: 'allow_loadBalancer_traffic'
    properties: {
      access: 'Allow'
      description: 'Outbound traffic through load balancer'
      destinationAddressPrefix: 'AzureLoadBalancer'
      destinationPortRange: '*'
      direction: 'Outbound'
      priority: 200
      protocol: 'Tcp'
      sourceAddressPrefix: '*'
      sourcePortRange: '*'
    }
  }
]
var outboundRuleConfigArray = [
  {
    name: 'outboundRuleForInit'
    properties: {
      backendAddressPool: {
        id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', externalLoadBalancerName, 'loadBalancerMgmtBackEnd')
      }
      frontendIPConfigurations: [
        {
          id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', externalLoadBalancerName, 'loadBalancerMgmtFrontEnd')
        }
      ]
      protocol: 'All'
    }
  }
]
var constructFrontEndIPConfigID = [for i in range(0, numberPublicExternalIpAddresses): {
  name: 'loadBalancerFrontEnd${i}'
  properties: {
    publicIPAddress: {
      id: resourceId('Microsoft.Network/publicIPAddresses', '${uniqueString_var}-app-pip${i}')
    }
  }
}]
var constructLoadBalancerRule = [for i in range(0, loadBalancerRulePortsLength): {
  name: 'app-${loadBalancerRulePorts[i]}'
  properties: {
    backendAddressPool: {
      id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', externalLoadBalancerName, 'loadBalancerBackEnd')
    }
    backendPort: loadBalancerRulePorts[i]
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', externalLoadBalancerName, 'loadBalancerFrontEnd0')
    }
    frontendPort: loadBalancerRulePorts[i]
    idleTimeoutInMinutes: 15
    loadDistribution: 'SourceIP'
    probe: {
      id: resourceId('Microsoft.Network/loadBalancers/probes', externalLoadBalancerName, 'tcp_probe_${loadBalancerRulePorts[i]}')
    }
    protocol: 'Tcp'
  }
}]
var constructLoadBalancerProbes = [for i in range(0, loadBalancerRulePortsLength): {
  name: 'tcp_probe_${loadBalancerRulePorts[i]}'
  properties: {
    intervalInSeconds: 15
    numberOfProbes: 3
    port: loadBalancerRulePorts[i]
    protocol: 'Tcp'
  }
}]
var constructLoadBalancerRuleInternal = [for i in range(0, loadBalancerRulePortsLength): {
  name: 'app-internal-${loadBalancerRulePorts[i]}'
  properties: {
    backendAddressPool: {
      id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', internalLoadBalancerName, 'loadBalancerBackEnd')
    }
    backendPort: loadBalancerRulePorts[i]
    frontendIPConfiguration: {
      id: resourceId('Microsoft.Network/loadBalancers/frontendIpConfigurations', internalLoadBalancerName, 'loadBalancerFrontEnd')
    }
    frontendPort: loadBalancerRulePorts[i]
    idleTimeoutInMinutes: 15
    loadDistribution: 'SourceIP'
    probe: {
      id: resourceId('Microsoft.Network/loadBalancers/probes', internalLoadBalancerName, 'tcp_probe_internal_${loadBalancerRulePorts[i]}')
    }
    protocol: 'Tcp'
  }
}]
var constructLoadBalancerProbesInternal = [for i in range(0, loadBalancerRulePortsLength): {
  name: 'tcp_probe_internal_${loadBalancerRulePorts[i]}'
  properties: {
    intervalInSeconds: 15
    numberOfProbes: 3
    port: loadBalancerRulePorts[i]
    protocol: 'Tcp'
  }
}]
var constructNsg0Array = [for i in range(0, nsg0Length): {
  name: 'nsg0_allow_${i}'
  properties: {
    access: 'Allow'
    description: 'NSG0 Allow'
    destinationAddressPrefix: '*'
    destinationPortRanges: nsg0[i].destinationPortRanges
    direction: 'Inbound'
    priority: int('10${i}')
    protocol: nsg0[i].protocol
    sourceAddressPrefix: nsg0[i].sourceAddressPrefix
    sourcePortRange: '*'
  }
}]
var constructNsg1Array = [for i in range(0, nsg1Length): {
  name: 'nsg1_allow_${i}'
  properties: {
    access: 'Allow'
    description: 'NSG1 Allow'
    destinationAddressPrefix: '*'
    destinationPortRanges: nsg1[i].destinationPortRanges
    direction: 'Inbound'
    priority: int('10${i}')
    protocol: nsg1[i].protocol
    sourceAddressPrefix: nsg1[i].sourceAddressPrefix
    sourcePortRange: '*'
  }
}]
var constructNsg2Array = [for i in range(0, nsg2Length): {
  name: 'nsg2_allow_${i}'
  properties: {
    access: 'Allow'
    description: 'NSG2 Allow'
    destinationAddressPrefix: '*'
    destinationPortRanges: nsg2[i].destinationPortRanges
    direction: 'Inbound'
    priority: int('10${i}')
    protocol: nsg2[i].protocol
    sourceAddressPrefix: nsg2[i].sourceAddressPrefix
    sourcePortRange: '*'
  }
}]
var constructNsg3Array = [for i in range(0, nsg3Length): {
  name: 'nsg3_allow_${i}'
  properties: {
    access: 'Allow'
    description: 'NSG3 Allow'
    destinationAddressPrefix: '*'
    destinationPortRanges: nsg3[i].destinationPortRanges
    direction: 'Inbound'
    priority: int('10${i}')
    protocol: nsg3[i].protocol
    sourceAddressPrefix: nsg3[i].sourceAddressPrefix
    sourcePortRange: '*'
  }
}]
var constructNsg4Array = [for i in range(0, nsg4Length): {
  name: 'nsg4_allow_${i}'
  properties: {
    access: 'Allow'
    description: 'NSG4 Allow'
    destinationAddressPrefix: '*'
    destinationPortRanges: nsg4[i].destinationPortRanges
    direction: 'Inbound'
    priority: int('10${i}')
    protocol: nsg4[i].protocol
    sourceAddressPrefix: nsg4[i].sourceAddressPrefix
    sourcePortRange: '*'
  }
}]

resource nsg0Name 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (!empty(nsg0)) {
  name: nsg0Name_var
  location: location
  tags: (empty(tagValues) ? json('null') : tagValues)
  properties: {
    securityRules: nsg0Array
  }
}

resource nsg1Name 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (!empty(nsg1)) {
  name: nsg1Name_var
  location: location
  tags: (empty(tagValues) ? json('null') : tagValues)
  properties: {
    securityRules: union(nsg1Array, outboundNsgRule)
  }
}

resource nsg2Name 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (!empty(nsg2)) {
  name: nsg2Name_var
  location: location
  tags: (empty(tagValues) ? json('null') : tagValues)
  properties: {
    securityRules: union(nsg2Array, outboundNsgRule)
  }
}

resource nsg3Name 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (!empty(nsg3)) {
  name: nsg3Name_var
  location: location
  tags: (empty(tagValues) ? json('null') : tagValues)
  properties: {
    securityRules: union(nsg3Array, outboundNsgRule)
  }
}

resource nsg4Name 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (!empty(nsg4)) {
  name: nsg4Name_var
  location: location
  tags: (empty(tagValues) ? json('null') : tagValues)
  properties: {
    securityRules: union(nsg4Array, outboundNsgRule)
  }
}

resource uniqueString_mgmt_pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = [for i in range(0, numberPublicMgmtIpAddresses): if (numberPublicMgmtIpAddresses > 0) {
  location: location
  name: '${uniqueString_var}-mgmt-pip${i}'
  properties: {
    dnsSettings: {
      domainNameLabel: '${uniqueString_var}-mgmt${(i + 0)}'
    }
    idleTimeoutInMinutes: 30
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
  tags: (empty(tagValues) ? json('null') : tagValues)
}]

resource uniqueString_app_pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = [for i in range(0, numberPublicExternalIpAddresses): if (numberPublicExternalIpAddresses > 0) {
  location: location
  name: '${uniqueString_var}-app-pip${i}'
  properties: {
    dnsSettings: {
      domainNameLabel: '${uniqueString_var}-app${(i + 0)}'
    }
    idleTimeoutInMinutes: 30
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
  tags: (empty(tagValues) ? json('null') : tagValues)
}]

resource externalLoadBalancerName_none_externalLoadBalancerName_none1 'Microsoft.Network/loadBalancers@2020-06-01' = if (toLower(externalLoadBalancerName) != string('none')) {
  location: location
  name: ((toLower(externalLoadBalancerName) != string('none')) ? externalLoadBalancerName : string('none1'))
  properties: {
    backendAddressPools: loadBalancerBackEndArray
    frontendIPConfigurations: appLoadBalancerFrontEnd
    inboundNatPools: ((numberPublicMgmtIpAddresses == 0) ? json('null') : inboundNatPoolsArray)
    loadBalancingRules: loadBalancingRulesArray
    outboundRules: ((numberPublicMgmtIpAddresses == 0) ? json('null') : outboundRuleConfigArray)
    probes: loadBalancingProbesArray
  }
  sku: {
    name: 'Standard'
  }
  tags: (empty(tagValues) ? json('null') : tagValues)
  dependsOn: [
    uniqueString_app_pip
  ]
}

resource internalLoadBalancerName_resource 'Microsoft.Network/loadBalancers@2020-06-01' = if (toLower(internalLoadBalancerName) != string('none')) {
  location: location
  name: internalLoadBalancerName
  properties: {
    backendAddressPools: [
      {
        name: 'loadBalancerBackEnd'
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'loadBalancerFrontEnd'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: internalSubnetId
          }
        }
      }
    ]
    loadBalancingRules: loadBalancingRulesArrayInternal
    probes: loadBalancingProbesArrayInternal
  }
  sku: {
    name: 'Standard'
  }
  tags: (empty(tagValues) ? json('null') : tagValues)
}

output externalIpIds array = [for i in range(0, numberPublicExternalIpAddresses): resourceId('Microsoft.Network/publicIPAddresses', '${uniqueString_var}-app-pip${i}')]
output externalIps array = [for i in range(0, numberPublicExternalIpAddresses): reference(resourceId('Microsoft.Network/publicIPAddresses', '${uniqueString_var}-app-pip${i}')).ipAddress]
output externalIpDns array = [for i in range(0, numberPublicExternalIpAddresses): reference(resourceId('Microsoft.Network/publicIPAddresses', '${uniqueString_var}-app-pip${i}')).dnsSettings.fqdn]
output externalBackEndLoadBalancerId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', externalLoadBalancerName, 'loadBalancerBackEnd')
output externalBackEndMgmtLoadBalancerId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', externalLoadBalancerName, 'loadBalancerMgmtBackEnd')
output externalFrontEndLoadBalancerId array = [for i in range(0, numberPublicExternalIpAddresses): resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', externalLoadBalancerName, 'loadBalancerFrontEnd${i}')]
output externalFrontEndLoadBalancerInboundId string = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', externalLoadBalancerName, 'loadBalancerMgmtFrontEnd')
output externalFrontEndMgmtLoadBalancerId string = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', externalLoadBalancerName, 'loadBalancerMgmtFrontEnd')
output externalLoadBalancer string = resourceId('Microsoft.Network/loadBalancers', externalLoadBalancerName)
output externalLoadBalancerProbesId array = [for i in range(0, loadBalancerRulePortsLength): resourceId('Microsoft.Network/loadBalancers/probes', externalLoadBalancerName, 'tcp_probe_${loadBalancerRulePorts[i]}')]
output externalLoadBalancerRulesId array = [for i in range(0, loadBalancerRulePortsLength): resourceId('Microsoft.Network/loadBalancers/loadBalancingRules', externalLoadBalancerName, 'app-${loadBalancerRulePorts[i]}')]
output inboundMgmtNatPool string = resourceId('Microsoft.Network/loadBalancers/inboundNatPools', externalLoadBalancerName, 'mgmtnatpool')
output inboundSshNatPool string = resourceId('Microsoft.Network/loadBalancers/inboundNatPools', externalLoadBalancerName, 'sshnatpool')
output internalBackEndLoadBalancerId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', internalLoadBalancerName, 'loadBalancerBackEnd')
output internalFrontEndLoadBalancerIp string = internalLoadBalancerName_resource.properties.frontendIPConfigurations[0].properties.privateIPAddress
output internalLoadBalancerProbesId array = [for i in range(0, loadBalancerRulePortsLength): resourceId('Microsoft.Network/loadBalancers/probes', internalLoadBalancerName, 'tcp_probe_internal_${loadBalancerRulePorts[i]}')]
output internalLoadBalancer string = internalLoadBalancerName_resource.id
output mgmtIpIds array = [for i in range(0, numberPublicMgmtIpAddresses): resourceId('Microsoft.Network/publicIPAddresses', '${uniqueString_var}-mgmt-pip${i}')]
output mgmtIps array = [for i in range(0, numberPublicMgmtIpAddresses): reference(resourceId('Microsoft.Network/publicIPAddresses', '${uniqueString_var}-mgmt-pip${i}')).ipAddress]
output nsg0Id string = nsg0Id[0]
output nsg1Id string = nsg1Id[0]
output nsg2Id string = nsg2Id[0]
output nsg3Id string = nsg3Id[0]
output nsg4Id string = nsg4Id[0]
output nsgIds array = union(nsg0Id, nsg1Id, nsg2Id, nsg3Id, nsg4Id)
