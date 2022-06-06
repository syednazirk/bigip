@description('REQUIRED - A prefix that will be used to name template resources. Because some resources require globally unique names, we recommend using a unique value.')
param uniqueString string

@description('Region Name')
param location string = ''

@description('VNET Resource Group Name')
param vnetResourceGroup string = ''

@description('VNET Name')
param vnetName string = ''

@description('Management SUBNET Name')
param mgmtSubnetName string = ''

@description('External SUBNET Name')
param extSubnetName string = ''

@description('Internal SUBNET Name')
param intSubnetName string = ''

@description('2 formats accepted. URN of the image to use in Azure marketplace or id of custom image. Example URN value: f5-networks:f5-big-ip-byol:f5-big-all-2slot-byol:15.1.501000. You can find the URNs of F5 marketplace images in the README for this template or by running the command: az vm image list --output yaml --publisher f5-networks --all. See https://clouddocs.f5.com/cloud/public/v1/azure/Azure_download.html for information on creating custom BIG-IP image.')
@allowed([
  'f5-networks:f5-big-ip-byol:f5-big-all-2slot-byol:15.1.501000'
  'f5-networks:f5-big-ip-best:f5-bigip-virtual-edition-25m-best-hourly:15.1.501000'
  'f5-networks:f5-big-ip-good:f5-bigip-virtual-edition-25m-good-hourly:15.1.501000'
])
param bigIpImage string = 'f5-networks:f5-big-ip-byol:f5-big-all-2slot-byol:15.1.501000'

@description('Enter valid instance type.')
@allowed([
  'Standard_DS3_v2'
  'Standard_DS5_v2'
])
param bigIpInstanceType string = 'Standard_DS3_v2'

@description('Type of authentication to use on the Virtual Machine, password based authentication or key based authentication.')
@allowed([
  'password'
  'sshPublicKey'
])
param authenticationType string = 'password'

@description('Password should be min 11 characters and comnination of atleast one lower case character, one upper case character, one numeral and one special character limited to (% * + , - . / : = ? [ ] ^ _ ~ space# )')
@secure()
param secret string = ''

@description('Enter valid License Key.')
param licenseKey string

@description('Enter valid number of network interfaces to create on the BIG-IP VE instance.')
@allowed([
  1
  2
  3
  4
  5
])
param numberOfNicCards int = 3

@description('Management Private IP Address for BIGIP Instance. IP address parameter must be in the form x.x.x.x.')
param bigIpMgmtSelfAddress string = ''

@description('External Private IP Address for BIGIP Instance. IP address parameter must be in the form x.x.x.x.')
param bigIpExternalSelfAddress string = ''

@description('Internal Private IP Address for BIGIP Instance. IP address parameter must be in the form x.x.x.x.')
param bigIpInternalSelfAddress string = ''

@description('REQUIRED - External private VIP Address for BIGIP Instance. IP address parameter must be in the form x.x.x.x. The address must reside in the same subnet and address space as the IP address provided for bigIpExternalSelfAddress.')
param servicePrivateIpAddress string = ''

@description('Enter valid number of public IPs to create on the BIG-IP VE instance.')
@allowed([
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
  11
  12
  13
  14
  15
  16
  17
  18
  19
  20
  21
  22
  23
  24
  25
  26
  27
  28
  29
  30
])
param numberOfPublicIps int = 3

@description('REQUIRED - When creating management security group, this field restricts management access to a specific network or address. Enter an IP address or address range in CIDR notation, or asterisk for all sources.')
param restrictedSrcAddressMgmt array = []

@description('Supply a URL to the bigip-runtime-init configuration file in YAML or JSON format, or an escaped JSON string to use for f5-bigip-runtime-init configuration.')
@allowed([
  'https://raw.githubusercontent.com/F5Networks/f5-azure-arm-templates-v2/v2.2.0.0/examples/quickstart/bigip-configurations/runtime-init-conf-3nic-byol.yaml'
  'https://raw.githubusercontent.com/F5Networks/f5-azure-arm-templates-v2/v2.2.0.0/examples/quickstart/bigip-configurations/runtime-init-conf-3nic-payg.yaml'
  'https://raw.githubusercontent.com/syednazirk/bigip2/main/runtime-init-conf-3nic-byol.yaml'
])
param bigIpRuntimeInitConfig string = 'https://raw.githubusercontent.com/syednazirk/bigip2/main/runtime-init-conf-3nic-byol.yaml'

@description('URL for BIG-IP Runtime Init package')
param bigIpRuntimeInitPackageUrl string = 'https://cdn.f5.com/product/cloudsolutions/f5-bigip-runtime-init/v1.4.2/dist/f5-bigip-runtime-init-1.4.2-1.gz.run'

@description('This deployment can deploy resources into Azure Availability Zones (if the region supports it).  If that is not desired the input should be set false. If the region does not support availability zones the input should be set to false.')
param useAvailabilityZones bool = false

@description('Enter user assigned management identity ID to be associated to vmss. Leave default if not used.')
param userAssignManagedIdentity string = ''

@description('Default key/value resource tags will be added to the resources in this deployment, if you would like the values to be unique adjust them as needed for each key.')
param tagValues object = {
  application: 'APP'
  cost: 'COST'
  environment: 'ENV'
  group: 'GROUP'
  owner: 'OWNER'
}

var uniqueString_var = toLower(uniqueString)
var adminUsername = string('kodiakf5')
var mgmtRulesArray = [
  {
    destinationPortRanges: [
      '22'
      '443'
    ]
    sourceAddressPrefixes: restrictedSrcAddressMgmt
    protocol: 'Tcp'
  }
]
var externalRulesArray = [
  {
    destinationPortRanges: []
    destinationAddressPrefix: '*'
    sourceAddressPrefixes: []
    protocol: '*'
  }
]
var mgmtSecurityGroup = mgmtRulesArray
var externalSecurityGroup = externalRulesArray
var vmName = '${uniqueString_var}-bigip-vm'
var vnetId = resourceId(vnetResourceGroup, 'Microsoft.Network/virtualNetworks', vnetName)
var extServicePrivateIpAddressArray = split(servicePrivateIpAddress, '.')
var extServicePrivateIpAddrPrefix = '${extServicePrivateIpAddressArray[0]}.${extServicePrivateIpAddressArray[1]}.${extServicePrivateIpAddressArray[2]}'
var extServicePrivateIpAddrSuffixInt = int(extServicePrivateIpAddressArray[3])

module dagTemplate 'ts:bd9593b1-8217-4859-b4cb-940a1e410122/MSI-IDC-DSN-F5KUBES/dagTemplate:3.0' = {
  name: 'dagTemplate'
  params: {
    uniqueString: uniqueString_var
    location: location
    nsg0: mgmtSecurityGroup
    nsg1: externalSecurityGroup
    numberPublicExternalIpAddresses: numberOfPublicIps
    tagValues: tagValues
  }
}

module bigIpTemplate 'ts:bd9593b1-8217-4859-b4cb-940a1e410122/MSI-IDC-DSN-F5KUBES/bigipTemplate:3.0' = {
  name: 'bigIpTemplate'
  params: {
    adminUsername: adminUsername
    location: location
    image: bigIpImage
    instanceType: bigIpInstanceType
    mgmtSubnetId: '${vnetId}/subnets/${mgmtSubnetName}'
    mgmtNsgId: dagTemplate.outputs.nsg0Id
    mgmtPublicIpId: dagTemplate.outputs.mgmtIpIds[0]
    mgmtSelfIp: bigIpMgmtSelfAddress
    nic1SubnetId: ((numberOfNicCards >= 2) ? '${vnetId}/subnets/${extSubnetName}' : '')
    nic1NsgId: ((numberOfNicCards >= 2) ? dagTemplate.outputs.nsg1Id : '')
    nic1SelfIp: ((numberOfNicCards >= 2) ? bigIpExternalSelfAddress : '')
    nic1ServiceIPs: [for j in range(0, numberOfPublicIps ): {
         publicIpId: dagTemplate.outputs.externalIpIds[j]
         privateIpAddress: '${extServicePrivateIpAddrPrefix}.${extServicePrivateIpAddrSuffixInt + j}'
      }]
    nic2SubnetId: ((numberOfNicCards >= 3) ? '${vnetId}/subnets/${intSubnetName}' : '')
    nic2PrimaryPublicId: ''
    nic2SelfIp: ((numberOfNicCards >= 3) ? bigIpInternalSelfAddress : '')
    nic2ServiceIPs: []
    roleDefinitionId: ''
    bigIpRuntimeInitPackageUrl: bigIpRuntimeInitPackageUrl
    bigIpRuntimeInitConfig: bigIpRuntimeInitConfig
    licenseKey: licenseKey
    secret: secret
    tagValues: tagValues
    uniqueString: uniqueString_var
    useAvailabilityZones: useAvailabilityZones
    userAssignManagedIdentity: ((!empty(userAssignManagedIdentity)) ? userAssignManagedIdentity : '')
    vmName: vmName
  }
}

output bigIpVmId string = bigIpTemplate.outputs.vmId
output bigIpManagementPublicIp string = dagTemplate.outputs.mgmtIps[0]
output bigIpManagementPrivateIp string = bigIpMgmtSelfAddress
output bigIpManagementPublicUrl string = ((numberOfNicCards == 1) ? 'https://${dagTemplate.outputs.mgmtIps[0]}:8443/' : 'https://${dagTemplate.outputs.mgmtIps[0]}:443/')
output bigIpManagementPrivateUrl string = ((numberOfNicCards == 1) ? 'https://${bigIpMgmtSelfAddress}:8443/' : 'https://${bigIpMgmtSelfAddress}:443/')
