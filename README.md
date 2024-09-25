# Introduction 
This project is designed to take all of the public topdesk API REST endpoints and wrap them in PowerShell cmdlets that can be consumed with automation. This is still a work in progress. 

# Current Status

# General API

## Archiving

| Endpoint                   | Method | Completed | cmdlet                      |
| -------------------------- | ------ | --------- | --------------------------- |
| /tas/api/archiving-reasons | GET    | Yes       | Get-TopdeskArchivingReasons |

## Email

| Endpoint                | Method | Completed | cmdlet |
| ----------------------- | ------ | --------- | ------ |
| /tas/api/emails/id/{id} | GET    | NO        |        |
| /tas/api/emails/id/{id} | DELETE | NO        |        |

## Service Windows

| Endpoint                           | Method | Completed | cmdlet                    |
| ---------------------------------- | ------ | --------- | ------------------------- |
| /tas/api/serviceWindow/lookup/     | GET    | Yes       | Get-TopdeskServiceWindows |
| /tas/api/serviceWindow/lookup/{id} | GET    | Yes       | Get-TopdeskServiceWindows |

## Timespent

| Endpoint                   | Method | Completed | cmdlet                      |
| -------------------------- | ------ | --------- | --------------------------- |
| /tas/api/timespent-reasons | GET    | Yes       | Get-TopdeskTimespentReasons |

## Version

| Endpoint                | Method | Completed | cmdlet                    |
| ----------------------- | ------ | --------- | ------------------------- |
| /tas/api/version        | GET    | Yes       | Get-TopdeskVersion        |
| /tas/api/productVersion | GET    | Yes       | Get-TopdeskProductVersion |

## Categories

| Endpoint            | Method | Completed | cmdlet                |
| ------------------- | ------ | --------- | --------------------- |
| /tas/api/categories | GET    | Yes       | Get-TopdeskCategories |

# Incident API

## Incident
| Endpoint                                                      | Method | Completed | cmdlet                        |
| ------------------------------------------------------------- | ------ | --------- | ----------------------------- |
| /tas/api/incidents                                            | GET    | Yes       | Get-TopdeskIncident           |
| /tas/api/incidents                                            | POST   | Yes       | New-TopdeskIncident           |
| /tas/api/incidents/id/{id}                                    | GET    | Yes       | Get-TopdeskIncident           |
| /tas/api/incidents/id/{id}                                    | PUT    | Yes       | Set-TopdeskIncident           |
| /tas/api/incidents/id/{id}                                    | PATCH  | Yes       | Set-TopdeskIncident           |
| /tas/api/incidents/number/{number}                            | GET    | Yes       | Get-TopdeskIncident           |
| /tas/api/incidents/number/{number}                            | PUT    | Yes       | Set-TopdeskIncident           |
| /tas/api/incidents/number/{number}                            | PATCH  | Yes       | Set-TopdeskIncident           |
| /tas/api/incidents/free_fields/{tab}/searchlists/{searchlist} | GET    | Yes       | Get-TopdeskIncidentSearchList |

## General
| Endpoint                         | Method | Completed | cmdlet                           |
| -------------------------------- | ------ | --------- | -------------------------------- |
| /tas/api/incidents/call_types    | GET    | Yes       | Get-TopdeskIncidentCallTypes     |
| /tas/api/incidents/durations     | GET    | Yes       | Get-TopdeskIncidentDurations     |
| /tas/api/incidents/entry_types   | GET    | Yes       | Get-TopdeskIncidentEntryTypes    |
| /tas/api/incidents/impacts       | GET    | Yes       | Get-TopdeskIncidentImpacts       |
| /tas/api/incidents/priorities    | GET    | Yes       | Get-TopdeskIncidentPriorities    |
| /tas/api/incidents/statuses      | GET    | Yes       | Get-TopdeskIncidentStatuses      |
| /tas/api/incidents/categories    | GET    | Yes       | Get-TopdeskIncidentCategory      |
| /tas/api/incidents/subcategories | GET    | Yes       | Get-TopdeskIncidentSubcategories |
| /tas/api/incidents/closure_codes | GET    | Yes       | Get-TopdeskIncidentClosureCodes  |
| /tas/api/incidents/urgencies     | GET    | Yes       | Get-TopdeskIncidentUrgencies     |
| /tas/api/incidents/slas          | GET    | Yes       | Get-TopdeskIncidentSLAS          |
| /tas/api/incidents/slas/services | GET    | Yes       | Get-TopdeskIncidentServices      |

## Time Registration
| Endpoint                                     | Method | Completed | cmdlet                       |
| -------------------------------------------- | ------ | --------- | ---------------------------- |
| /tas/api/incidents/id/{id}/timespent         | GET    | Yes       | Get-TopdeskIncidentTimespent |
| /tas/api/incidents/id/{id}/timespent         | POST   | Yes       | Add-TopdeskIncidentTimespent |
| /tas/api/incidents/number/{number}/timespent | GET    | Yes       | Get-TopdeskIncidentTimespent |
| /tas/api/incidents/number/{number}/timespent | POST   | Yes       | Add-TopdeskIncidentTimespent |
| /tas/api/incidents/timeregistrations         | GET    | Yes       | Get-TopdeskTimeRegistrations |
| /tas/api/incidents/timeregistrations/{id}    | GET    | Yes       | Get-TopdeskTimeRegistrations |

## progress trail / actions / requests
| Endpoint                                                        | Method | Completed | cmdlet                           |
| --------------------------------------------------------------- | ------ | --------- | -------------------------------- |
| /tas/api/incidents/id/{id}/progresstrail                        | GET    | Yes       | Get-TopdeskIncidentProgressTrail |
| /tas/api/incidents/number/{number}/progresstrail                | GET    | Yes       | Get-TopdeskIncidentProgressTrail |
| /tas/api/incidents/id/{id}/progresstrail/count                  | GET    | Yes       | Get-TopdeskIncidentProgressTrail |
| /tas/api/incidents/number/{number}/progresstrail/count          | GET    | Yes       | Get-TopdeskIncidentProgressTrail |
| /tas/api/incidents/number/{number}/actions                      | GET    | Yes       | Get-TopdeskIncidentAtions        |
| /tas/api/incidents/id/{id}/actions                              | GET    | Yes       | Get-TopdeskIncidentAtions        |
| /tas/api/incidents/id/{incidentid}/actions/{actionid}           | GEt    | Yes       | Get-TopdeskIncidentAtions        |
| /tas/api/incidents/id/{incidentid}/actions/{actionid}           | DELETE | Yes       | Remove-TopdeskIncidentAction     |
| /tas/api/incidents/number/{incidentnumber}/actions/{actionid}   | GET    | Yes       | Get-TopdeskIncidentAtions        |
| /tas/api/incidents/number/{incidentnumber}/actions/{actionid}   | DELETE | Yes       | Remove-TopdeskIncidentAction     |
| /tas/api/incidents/number/{number}/requests                     | GET    | Yes       | Get-TopdeskIncidentRequests      |
| /tas/api/incidents/id/{id}/requests                             | GET    | Yes       | Get-TopdeskIncidentRequests      |
| /tas/api/incidents/id/{incidentid}/requests/{requestid}         | GET    | Yes       | Get-TopdeskIncidentRequests      |
| /tas/api/incidents/id/{incidentid}/requests/{requestid}         | DELETE | Yes       | Remove-TopdeskIncidentRequest    |
| /tas/api/incidents/number/{incidentnumber}/requests/{requestid} | GET    | Yes       | Get-TopdeskIncidentRequests      |
| /tas/api/incidents/number/{incidentnumber}/requests/{requestid} | DELETE | Yes       | Remove-TopdeskIncidentRequest    |

## escalation / deescalation
| Endpoint                                      | Method | Completed | cmdlet                                 |
| --------------------------------------------- | ------ | --------- | -------------------------------------- |
| /tas/api/incidents/id/{id}/escalate           | PUT    | Yes       | Set-TopdeskIncidentEscalation          |
| /tas/api/incidents/number/{number}/escalate   | PUT    | Yes       | Set-TopdeskIncidentEscalation          |
| /tas/api/incidents/id/{id}/deescalate         | PUT    | Yes       | Set-TopdeskIncidentDeescalation        |
| /tas/api/incidents/number/{number}/deescalate | PUT    | Yes       | Set-TopdeskIncidentDeescalation        |
| /tas/api/incidents/deescalation-reasons       | GET    | Yes       | Get-TopdeskIncidentDeescalationReasons |
| /tas/api/incidents/escalation-reasons         | GET    | Yes       | Get-TopdeskIncidentEscalationReasons   |

## archive / unarchive
| Endpoint                                     | Method | Completed | cmdlet                       |
| -------------------------------------------- | ------ | --------- | ---------------------------- |
| /tas/api/incidents/id/{id}/archive           | PUT    | Yes       | Set-TopdeskIncidentArchive   |
| /tas/api/incidents/number/{number}/archive   | PUT    | Yes       | Set-TopdeskIncidentArchive   |
| /tas/api/incidents/id/{id}/unarchive         | PUT    | Yes       | Set-TopdeskIncidentUnarchive |
| /tas/api/incidents/number/{number}/unarchive | PUT    | Yes       | Set-TopdeskIncidentUnarchive |

## attachments
| Endpoint                                                               | Method | Completed | cmdlet                                |
| ---------------------------------------------------------------------- | ------ | --------- | ------------------------------------- |
| /tas/api/incidents/id/{incidentId}/attachments/{attachmentId}          | DELETE | Yes       | Remove-TopdeskIncidentAttachment      |
| /tas/api/incidents/number/{incidentNumber}/attachments/{attachmentId}  | DELETE | Yes       | Remove-TopdeskIncidentAttachment      |
| /tas/api/incidents/id/{incidentId}/attachments/{attachmentId}/download | GET    | Yes       | Get-TopdeskIncidentAttachmentDownload |
| /tas/api/incidents/id/{incidentId}/attachments                         | GET    | Yes       | Get-TopdeskIncidentAttachments        |
| /tas/api/incidents/id/{incidentId}/attachments                         | POST   | Yes       | New-TopdeskIncidentAttachment         |
| /tas/api/incidents/number/{incidentNumber}/attachments                 | GET    | Yes       | Get-TopdeskIncidentAttachments        |
| /tas/api/incidents/number/{incidentNumber}/attachments                 | POST   | Yes       | New-TopdeskIncidentAttachment         |

# Knowledge Items API

## Knowledge Items
| Endpoint                                                                                            | Method | Completed | cmdlet                                     |
| --------------------------------------------------------------------------------------------------- | ------ | --------- | ------------------------------------------ |
| /services/knowledge-base-v1/knowledgeItems                                                          | GET    | Yes       | Get-TopdeskKnowledgeItem                   |
| /services/knowledge-base-v1/knowledgeItems                                                          | POST   | Yes       | New-TopdeskKnowledgeItem                   |
| /services/knowledge-base-v1/knowledgeItems/{identifier}                                             | GET    | Yes       | Get-TopdeskKnowledgeItem                   |
| /services/knowledge-base-v1/knowledgeItems/{identifier}                                             | POST   | Yes       | Update-TopdeskKnowledgeItem                |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/archive                                     | POST   | Yes       | Set-TopdeskKnowledgeItemArchive            |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/unarchive                                   | POST   | Yes       | Set-TopdeskKnowledgeItemArchive            |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/translations                                | POST   | Yes       | New-TopdeskKnowledgeItemTranslation        |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/translations/{language}                     | POST   | Yes       | Update-TopdeskKnowledgeItemTranslation     |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/translations/{language}                     | DELETE | Yes       | Remove-TopdeskKnowledgeItemTranslation     |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/branches                                    | GET    | Yes       | Get-TopdedeskKnowledgebaseBranches         |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/branches/link                               | POST   | Yes       | Add-TopdeskKnowledgeItemBranchesLink       |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/branches/unlink                             | POST   | Yes       | Remove-TopdeskKnowledgeItemBranchesLink    |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/giveFeedback                                | POST   | Yes       | Add-TopdeskKnowledgeItemFeedback           |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/images                                      | GET    | Yes       | Get-TopdeskKnowledgeItemImages             |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/images                                      | POST   | Yes       | New-TopdeskKnowledgeItemImage              |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/images/{imageName}/download                 | GET    | Yes       | Get-TopdeskKnowledgeItemImageDownload      |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/images/{imageName}                          | DELETE | Yes       | Remove-TopdeskKnowledgeItemImage           |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/attachments                                 | GET    | Yes       | Get-TopdeskKnowledgeItemAttachments        |
| /tas/api/knowledgeItems/{identifier}/attachments                                                    | POST   | Yes       | New-TopdeskKnowledgeItemAttachment         |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/attachments/{attachmentIdentifier}/download | GET    | Yes       | Get-TopdeskKnowledgeItemAttachmentDownload |
| /services/knowledge-base-v1/knowledgeItems/{identifier}/attachments/{attachmentIdentifier}          | DELETE | Yes       | Remove-TopdeskKnowledgeItemAtttachment     |

## Searchlists
| Endpoint                                                                 | Method | Completed | cmdlet                                  |
| ------------------------------------------------------------------------ | ------ | --------- | --------------------------------------- |
| /services/knowledge-base-v1/knowledgeItemStatuses                        | GET    | Yes       | Get-TopdeskKnowledgeItemStatues         |
| /services/knowledge-base-v1/knowledgeItemStatuses                        | POST   | Yes       | New-TopdeskKnowledgeItemStatues         |
| /services/knowledge-base-v1/knowledgeItemStatuses/{identifier}           | PATCH  | Yes       | Update-TopdeskKnowledgeItemStatues      |
| /services/knowledge-base-v1/knowledgeItemStatuses/{identifier}/archive   | POST   | Yes       | Set-TopdeskKnowledgeItemStatusArchive   |
| /services/knowledge-base-v1/knowledgeItemStatuses/{identifier}/unarchive | POST   | Yes       | Set-TopdeskKnowledgeItemStatusUnarchive |

# Reservation Management API

## Reservations
| Endpoint                                                     | Method | Completed | cmdlet |
| ------------------------------------------------------------ | ------ | --------- | ------ |
| /tas/api/reservations                                        | GET    | No        |        |
| /tas/api/reservations                                        | POST   | No        |        |
| /tas/api/reservations/{identifier}                           | GET    | No        |        |
| /tas/api/reservations/{identifier}                           | PATCH  | No        |        |
| /tas/api/reservations/{identifier}/approve                   | POST   | No        |        |
| /tas/api/reservations/{identifier}/attachments               | GET    | No        |        |
| /tas/api/reservations/{identifier}/attachments               | POST   | No        |        |
| /tas/api/reservations/{identifier}/cancel                    | POST   | No        |        |
| /tas/api/reservations/{identifier}/makeRecurrent/dates       | POST   | No        |        |
| /tas/api/reservations/{identifier}/occurrences/dates         | POST   | No        |        |
| /tas/api/reservations/{identifier}/occurrences/dates         | PUT    | No        |        |
| /tas/api/reservations/{identifier}/participants/add          | POST   | No        |        |
| /tas/api/reservations/{identifier}/participants/remove       | POST   | No        |        |
| /tas/api/reservations/{identifier}/reject                    | POST   | No        |        |
| /tas/api/reservations/{identifier}/reschedule                | POST   | No        |        |
| /tas/api/reservations/{identifier}/reservedFacilities/add    | POST   | No        |        |
| /tas/api/reservations/{identifier}/reservedFacilities/move   | POST   | No        |        |
| /tas/api/reservations/{identifier}/reservedFacilities/remove | POST   | No        |        |
| /tas/api/reservations/{identifier}/reservedServices          | POST   | No        |        |

## Reservable Facilities
| Endpoint                                                  | Method | Completed | cmdlet |
| --------------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/reservableAssets                                 | GET    | No        |        |
| /tas/api/reservableAssets/{identifier}/reservableInterval | GET    | No        |        |
| /tas/api/reservableLocations                              | GET    | No        |        |
| /tas/api/reservableLocations/{id}                         | GET    | No        |        |
| /tas/api/reservableLocations/{id}/reservableInterval      | GET    | No        |        |

## Reservable Services
| Endpoint                         | Method | Completed | cmdlet |
| -------------------------------- | ------ | --------- | ------ |
| /tas/api/reservableServices      | GET    | No        |        |
| /tas/api/reservableServices/{id} | GET    | No        |        |

## Searchlists
| Endpoint                                                       | Method | Completed | cmdlet |
| -------------------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/reservationCancellationReasons                        | GET    | No        |        |
| /tas/api/reservationCancellationReasons                        | POST   | No        |        |
| /tas/api/reservationCancellationReasons/{identifier}           | PATCH  | No        |        |
| /tas/api/reservationCancellationReasons/{identifier}/archive   | POST   | No        |        |
| /tas/api/reservationCancellationReasons/{identifier}/unarchive | POST   | No        |        |
| /tas/api/reservationProcessingStatus                           | GET    | No        |        |
| /tas/api/reservationProcessingStatus                           | POST   | No        |        |
| /tas/api/reservationProcessingStatus/{identifier}              | PATCH  | No        |        |
| /tas/api/reservationProcessingStatus/{identifier}/archive      | POST   | No        |        |
| /tas/api/reservationProcessingStatus/{identifier}/unarchive    | POST   | No        |        |
| /tas/api/reservationRejectionReasons                           | GET    | No        |        |
| /tas/api/reservationRejectionReasons                           | POST   | No        |        |
| /tas/api/reservationRejectionReasons/{identifier}              | PATCH  | No        |        |
| /tas/api/reservationRejectionReasons/{identifier}/archive      | POST   | No        |        |
| /tas/api/reservationRejectionReasons/{identifier}/archive      | POST   | No        |        |
| /tas/api/serviceTypes                                          | GET    | No        |        |
| /tas/api/serviceTypes                                          | POST   | No        |        |
| /tas/api/serviceTypes/{identifier}                             | PATCH  | No        |        |
| /tas/api/serviceTypes/{identifier}/archive                     | POST   | No        |        |
| /tas/api/serviceTypes/{identifier}/unarchive                   | POST   | No        |        |

## Facility Occupancies
| Endpoint                     | Method | Completed | cmdlet |
| ---------------------------- | ------ | --------- | ------ |
| /tas/api/facilityOccupancies | GET    | No        |        |

# Services API

## Services
| Endpoint                                       | Method | Completed | cmdlet |
| ---------------------------------------------- | ------ | --------- | ------ |
| /tas/api/services                              | GET    | No        |        |
| /tas/api/services                              | POST   | No        |        |
| /tas/api/services/{id}                         | GET    | No        |        |
| /tas/api/services/{id}/linkedAssets            | GET    | No        |        |
| /tas/api/services/{id}/linkedAssets            | POST   | No        |        |
| /tas/api/services/{id}/linkedAssets/{objectId} | PUT    | No        |        |
| /tas/api/services/{id}/linkedAssets/{objectId} | DELETE | No        |        |

# Change Management API

## Manager Authorizations
| Endpoint                                                                      | Method | Completed | cmdlet |
| ----------------------------------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/managerAuthorizables                                                 | GET    | No        |        |
| /tas/api/managerAuthorizableChanges/{id}                                      | GET    | No        |        |
| /tas/api/managerAuthorizableChanges/{id}/progresstrail                        | GET    | No        |        |
| /tas/api/managerAuthorizableChanges/{id}/progresstrail                        | POST   | No        |        |
| /tas/api/managerAuthorizableChanges/{entityId}/attachments/{attachmentId}     | GET    | No        |        |
| /tas/api/managerAuthorizableChanges/{id}/attachments                          | POST   | No        |        |
| /tas/api/managerAuthorizableChanges/{id}/requests                             | GET    | No        |        |
| /tas/api/managerAuthorizableChanges/{id}/orderedItems                         | GET    | No        |        |
| /tas/api/managerAuthorizableChanges/{id}/processingStatusTransitions          | POST   | No        |        |
| /tas/api/managerAuthorizableActivities/{id}                                   | GET    | No        |        |
| /tas/api/managerAuthorizableActivities/{id}/managerAction                     | PUT    | No        |        |
| /tas/api/managerAuthorizableActivities/{id}/progresstrail                     | GET    | No        |        |
| /tas/api/managerAuthorizableActivities/{id}/progresstrail                     | POST   | No        |        |
| /tas/api/managerAuthorizableActivities/{entityId}/attachments/{attachmentId}  | GET    | No        |        |
| /tas/api/managerAuthorizableActivities/{id}/attachments                       | POST   | No        |        |
| /tas/api/managerAuthorizableActivities/{id}/requests                          | GET    | No        |        |
| /tas/api/managerAuthorizableActivities/{id}/change/progresstrail              | GET    | No        |        |
| /tas/api/managerAuthorizableActivities/{id}/change/requests                   | GET    | No        |        |
| /tas/api/managerAuthorizableActivities/{id}/change/attachments/{attachmentId} | GET    | No        |        |
| /tas/api/changeRejectionReasons                                               | GET    | No        |        |
| /tas/api/changeActivityRejectionReasons                                       | GET    | No        |        |

## Requester Changes
| Endpoint                                                        | Method | Completed | cmdlet |
| --------------------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/requesterChanges                                       | GET    | No        |        |
| /tas/api/requesterChanges/{id}                                  | GET    | No        |        |
| /tas/api/requesterChanges/{entityId}/attachments/{attachmentId} | GET    | No        |        |
| /tas/api/requesterChanges/{id}/attachments                      | POST   | No        |        |
| /tas/api/requesterChanges/{id}/progresstrail                    | GET    | No        |        |
| /tas/api/requesterChanges/{id}/progresstrail                    | POST   | No        |        |
| /tas/api/requesterChanges/{id}/requests                         | GET    | No        |        |
| /tas/api/requesterChanges/{id}/orderedItems                     | GEt    | No        |        |

## Working as an operator
| Endpoint                                                                      | Method | Completed | cmdlet                                 |
| ----------------------------------------------------------------------------- | ------ | --------- | -------------------------------------- |
| /tas/api/operatorChanges                                                      | GET    | Yes       | Get-TopdeskOperatorChanges             |
| /tas/api/operatorChanges                                                      | POST   | No        |                                        |
| /tas/api/operatorChanges/{identifier}                                         | PATCH  | No        |                                        |
| /tas/api/operatorChanges/{identifier}                                         | GET    | Yes       | Get-TopdeskOperatorChanges             |
| /tas/api/operatorChanges/{identifier}/cancel                                  | POST   | No        |                                        |
| /tas/api/operatorChanges/{identifier}/processingStatusTransitions             | POST   | No        |                                        |
| /tas/api/operatorChanges/{id}/requests                                        | GET    | No        |                                        |
| /tas/api/operatorChanges/{identifier}/requests/{requestId}                    | DELETE | No        |                                        |
| /tas/api/operatorChanges/{identifier}/actions/{actionId}                      | DELETE | No        |                                        |
| /tas/api/operatorChanges/{id}/progresstrail                                   | GET    | No        |                                        |
| /tas/api/operatorChanges/{id}/progresstrail                                   | POST   | No        |                                        |
| /tas/api/operatorChanges/{id}/attachments                                     | POST   | No        |                                        |
| /tas/api/operatorChanges/{entityId}/attachments/{attachmentId}                | GET    | No        |                                        |
| /tas/api/operatorChanges/{entityId}/attachments/{attachmentId}                | DELETE | No        |                                        |
| /tas/api/operatorChanges/optionalFields/{tabNumber}/{searchlistName}          | GET    | No        |                                        |
| /tas/api/operatorChanges/{id}/persons                                         | GET    | No        |                                        |
| /tas/api/operatorChanges/{id}/persons                                         | POST   | No        |                                        |
| /tas/api/operatorChanges/{id}/persons                                         | DELETE | No        |                                        |
| /tas/api/operatorChanges/{id}/orderedItems                                    | GET    | Yes       | Get-TopdeskOperatorChangesOrderedItems |
| /tas/api/operatorChanges/{id}/orderedItems                                    | POST   | No        |                                        |
| /tas/api/operatorChanges/{id}/orderedItems                                    | DELETE | No        |                                        |
| /tas/api/operatorChangeActivities                                             | GET    | No        |                                        |
| /tas/api/operatorChangeActivities                                             | POST   | No        |                                        |
| /tas/api/operatorChangeActivities/{identifier}                                | PATCH  | No        |                                        |
| /tas/api/operatorChangeActivities/{identifier}                                | GET    | No        |                                        |
| /tas/api/operatorChangeActivities/{id}/requests                               | GET    | No        |                                        |
| /tas/api/operatorChangeActivities/{identifier}/requests/{requestId}           | DELETE | No        |                                        |
| /tas/api/operatorChangeActivities/{id}/progresstrail                          | GET    | No        |                                        |
| /tas/api/operatorChangeActivities/{id}/progresstrail                          | POST   | No        |                                        |
| /tas/api/operatorChangeActivities/{identifier}/actions/{actionId}             | DELETE | No        |                                        |
| /tas/api/operatorChangeActivities/{id}/attachments                            | POST   | No        |                                        |
| /tas/api/operatorChangeActivities/{entityId}/attachments/{attachmentId}       | GET    | No        |                                        |
| /tas/api/operatorChangeActivities/{entityId}/attachments/{attachmentId}       | DELETE | No        |                                        |
| /tas/api/operatorChangeActivities/optionalFields/{tabNumber}/{searchlistName} | GET    | No        |                                        |
| /tas/api/changeCalendar                                                       | GET    | No        |                                        |
| /tas/api/changeCalendar/{id}                                                  | GET    | No        |                                        |
| /tas/api/changeCalendar/{id}/requests                                         | GET    | No        |                                        |
| /tas/api/changeCalendar/{id}/progresstrail                                    | GET    | No        |                                        |
| /tas/api/changeCalendar/{entityId}/attachments/{attachmentId}                 | GET    | No        |                                        |
| /tas/api/applicableChangeTemplates                                            | GET    | No        |                                        |
| /tas/api/changes/settings                                                     | GET    | No        |                                        |

## Searchlists
| Endpoint                          | Method | Completed | cmdlet |
| --------------------------------- | ------ | --------- | ------ |
| /tas/api/changes/changeStatuses   | GET    | No        |        |
| /tas/api/changes/activityStatuses | GET    | No        |        |
| /tas/api/changes/benefits         | GET    | No        |        |
| /tas/api/changes/impacts          | GET    | No        |        |

# Asset Management REST API

## Assets
| Endpoint                                                 | Method | Completed | cmdlet              |
| -------------------------------------------------------- | ------ | --------- | ------------------- |
| /tas/api/assetmgmt/assets                                | GET    | Yes       | Get-TopdeskAsset    |
| /tas/api/assetmgmt/assets                                | POST   | No        |                     |
| /tas/api/assetmgmt/assets/blank                          | GET    | No        |                     |
| /tas/api/assetmgmt/assets/delete                         | POST   | No        |                     |
| /tas/api/assetmgmt/assets/deleteGridFieldAsset           | POST   | No        |                     |
| /tas/api/assetmgmt/assets/filter                         | POST   | No        |                     |
| /tas/api/assetmgmt/assets/getGridFieldValues             | GET    | No        |                     |
| /tas/api/assetmgmt/assets/gridFieldAsset                 | GET    | No        |                     |
| /tas/api/assetmgmt/assets/gridFieldAsset                 | POST   | No        |                     |
| /tas/api/assetmgmt/assets/{assetId}                      | GET    | Yes       | Get-TopdeskAsset    |
| /tas/api/assetmgmt/assets/{assetId}                      | POST   | Yes       | Update-TopdeskAsset |
| /tas/api/assetmgmt/assets/{assetId}/archive              | POST   | No        |                     |
| /tas/api/assetmgmt/assets/{assetId}/copy                 | POST   | No        |                     |
| /tas/api/assetmgmt/assets/{assetId}/history/currentItems | GET    | No        |                     |
| /tas/api/assetmgmt/assets/{assetId}/history/pastItems    | GET    | No        |                     |
| /tas/api/assetmgmt/assets/{assetId}/unarchive            | POST   | No        |                     |

## Asset links
| Endpoint                                                 | Method | Completed | cmdlet |
| -------------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/assetmgmt/capabilities                          | GET    | No        |        |
| /tas/api/assetmgmt/capabilities                          | POST   | No        |        |
| /tas/api/assetmgmt/capabilities/{capabilityId}           | GET    | No        |        |
| /tas/api/assetmgmt/capabilities/{capabilityId}           | POST   | No        |        |
| /tas/api/assetmgmt/capabilities/{capabilityId}/archive   | POST   | No        |        |
| /tas/api/assetmgmt/capabilities/{capabilityId}/unarchive | POST   | No        |        |

## Assignments
| Endpoint                                                 | Method | Completed | cmdlet                         |
| -------------------------------------------------------- | ------ | --------- | ------------------------------ |
| /tas/api/assetmgmt/assets/Assignments                    | PUT    | Yes       | Set-TopdeskAssetAssignments    |
| /tas/api/assetmgmt/assets/unlink/{type}/{targetId}       | POST   | Yes       | Remove-TopdeskAssetAssignments |
| /tas/api/assetmgmt/assets/{assetId}/assignments          | GET    | Yes       | Get-TopdeskAssetAssignments    |
| /tas/api/assetmgmt/assets/{assetId}/assignments          | PUT    | Yes       | Set-TopdeskAssetAssignments    |
| /tas/api/assetmgmt/assets/{assetId}/assignments/{linkId} | DELETE | Yes       | Remove-TopdeskAssetAssignments |

## Fields
| Endpoint                            | Method | Completed | cmdlet                   |
| ----------------------------------- | ------ | --------- | ------------------------ |
| /tas/api/assetmgmt/fields           | GET    | Yes       | Get-TopdeskAssetFields   |
| /tas/api/assetmgmt/fields/{fieldId} | DELETE | Yes       | Remove-TopdeskAssetField |
| /tas/api/assetmgmt/fields/{fieldId} | GET    | Yes       | Get-TopdeskAssetFields   |

## Templates
| Endpoint                     | Method | Completed | cmdlet                    |
| ---------------------------- | ------ | --------- | ------------------------- |
| /tas/api/assetmgmt/templates | GET    | Yes       | Get-TopdeskAssetTemplates |

## Uploads
| Endpoint                              | Method | Completed | cmdlet                    |
| ------------------------------------- | ------ | --------- | ------------------------- |
| /tas/api/assetmgmt/uploads            | GET    | Yes       | Get-TopdeskAssetUpload    |
| /tas/api/assetmgmt/uploads            | POST   | Yes       | New-TopdeskAssetUpload    |
| /tas/api/assetmgmt/uploads/{uploadId} | DELETE | Yes       | Remove-TopdeskAssetUpload |

## Stock Quantities
| Endpoint                                | Method | Completed | cmdlet |
| --------------------------------------- | ------ | --------- | ------ |
| /tas/api/assetmgmt/stockQuantities      | GET    | No        |        |
| /tas/api/assetmgmt/stockQuantities      | POST   | No        |        |
| /tas/api/assetmgmt/stockQuantities/{id} | DELETE | No        |        |
| /tas/api/assetmgmt/stockQuantities/{id} | PUT    | No        |        |
| /tas/api/assetmgmt/stockTotals          | GET    | No        |        |

## Asset Management Import API

| Endpoint                                                                            | Method | Completed | cmdlet                       |
| ----------------------------------------------------------------------------------- | ------ | --------- | ---------------------------- |
| /tas/api/assetmgmt/assetStatuses                                                    | GET    | No        |                              |
| /tas/api/assetmgmt/assets/templateId/{templateId}                                   | GET    | No        |                              |
| /tas/api/assetmgmt/assets/templateId/{templateId}                                   | POST   | No        |                              |
| /tas/api/assetmgmt/assets/templateId/{templateId}/{assetId}                         | PATCH  | No        |                              |
| /tas/api/assetmgmt/assets/templateId/{templateId}/{assetId}/archive                 | POST   | No        |                              |
| /tas/api/assetmgmt/assets/templateId/{templateId}/{assetId}/assignment/branches     | PUT    | No        |                              |
| /tas/api/assetmgmt/assets/templateId/{templateId}/{assetId}/assignment/locations    | PUT    | No        |                              |
| /tas/api/assetmgmt/assets/templateId/{templateId}/{assetId}/assignment/personGroups | PUT    | No        |                              |
| /tas/api/assetmgmt/assets/templateId/{templateId}/{assetId}/assignment/persons      | PUT    | No        |                              |
| /tas/api/assetmgmt/cardTypes                                                        | GET    | No        |                              |
| /tas/api/assetmgmt/dropdowns/{dropdownId}                                           | GET    | Yes       | Get-TopdeskAssetDropdown     |
| /tas/api/assetmgmt/dropdowns/{dropdownId}                                           | POST   | No        |                              |
| /tas/api/assetmgmt/import/assets                                                    | GET    | No        |                              |
| /tas/api/assetmgmt/import/assets/{assetId}/links/child                              | PUT    | No        |                              |
| /tas/api/assetmgmt/import/assets/{assetId}/links/incoming/{linkTypeId}              | PUT    | No        |                              |
| /tas/api/assetmgmt/import/assets/{assetId}/links/outgoing/{linkTypeId}              | PUT    | No        |                              |
| /tas/api/assetmgmt/import/assets/{assetId}/links/parent                             | PUT    | No        |                              |
| /services/import-to-api-v1/api/sourceFiles?filename=$($fileName)                    | PUT    | Yes       | New-TopdeskAssetImportUpload |

## Knowledge Items
| Endpoint                                      | Method | Completed | cmdlet |
| --------------------------------------------- | ------ | --------- | ------ |
| /tas/api/assetmgmt/assets/linkedKnowledgeItem | POST   | No        |        |

## Services
| Endpoint                                | Method | Completed | cmdlet |
| --------------------------------------- | ------ | --------- | ------ |
| /tas/api/assetmgmt/assets/linkedService | POST   | No        |        |

## Tasks
| Endpoint                             | Method | Completed | cmdlet |
| ------------------------------------ | ------ | --------- | ------ |
| /tas/api/assetmgmt/assets/linkedTask | POST   | No        |        |

## Actions
| Endpoint                                    | Method | Completed | cmdlet |
| ------------------------------------------- | ------ | --------- | ------ |
| /tas/api/assetmgmt/assets/{assetId}/actions | GET    | Yes       |        |

# Operations Management API

## Operational Activities
| Endpoint                                                                        | Method | Completed | cmdlet |
| ------------------------------------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/operationalActivities                                                  | GET    | No        |        |
| /tas/api/operationalActivities                                                  | POST   | No        |        |
| /tas/api/operationalActivities/settings                                         | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}                                     | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}                                     | PATCH  | No        |        |
| /tas/api/operationalActivities/{identifier}/linkedObjects                       | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}/linkedAssets                        | POST   | No        |        |
| /tas/api/operationalActivities/{identifier}/linkedLocations                     | POST   | No        |        |
| /tas/api/operationalActivities/{identifier}/linkedBranches                      | POST   | No        |        |
| /tas/api/operationalActivities/{identifier}/timeRegistrations                   | POST   | No        |        |
| /tas/api/operationalActivities/{identifier}/timeRegistrations                   | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}/requests                            | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}/requests/{requestId}                | POST   | No        |        |
| /tas/api/operationalActivities/{identifier}/actions                             | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}/actions                             | POST   | No        |        |
| /tas/api/operationalActivities/{identifier}/attachments                         | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}/attachments/upload                  | POST   | No        |        |
| /tas/api/operationalActivities/{identifier}/attachments/{attachmentId}/download | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}/emails                              | GET    | No        |        |
| /tas/api/operationalActivities/{identifier}/emails/{emailId}                    | GEt    | No        |        |

## Searchlists
| Endpoint                                          | Method | Completed | cmdlet |
| ------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/operationalActivities/statuses           | GET    | No        |        |
| /tas/api/operationalActivities/reasonsForSkipping | GET    | No        |        |
| /tas/api/operationalActivities/reasonsForAnomaly  | GET    | No        |        |
| /tas/api/operationalActivities/types              | GET    | No        |        |
| /tas/api/operationalActivities/schemas            | GET    | No        |        |
| /tas/api/operationalActivities/groupings          | GET    | No        |        |

## Operational Series
| Endpoint                                | Method | Completed | cmdlet |
| --------------------------------------- | ------ | --------- | ------ |
| /tas/api/operationalSeries/{identifier} | GET    | No        |        |

# Visitor Registration API

## Visitors
| Endpoint                                                                     | Method | Completed | cmdlet |
| ---------------------------------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/badges                                                              | GET    | No        |        |
| /tas/api/badges                                                              | POST   | No        |        |
| /tas/api/badges/{identifier}                                                 | PATCH  | No        |        |
| /tas/api/badges/{identifier}/archive                                         | POST   | No        |        |
| /tas/api/badges/{identifier}/unarchive                                       | POST   | No        |        |
| /tas/api/carParks                                                            | GET    | No        |        |
| /tas/api/carParks                                                            | POST   | No        |        |
| /tas/api/carParks/{identifier}                                               | PATCH  | No        |        |
| /tas/api/carParks/{identifier}/archive                                       | POST   | No        |        |
| /tas/api/carParks/{identifier}/unarchive                                     | POST   | No        |        |
| /tas/api/identificationTypes                                                 | GET    | No        |        |
| /tas/api/identificationTypes                                                 | POST   | No        |        |
| /tas/api/identificationTypes/{identifier}                                    | PATCH  | No        |        |
| /tas/api/identificationTypes/{identifier}/archive                            | POST   | No        |        |
| /tas/api/identificationTypes/{identifier}/unarchive                          | POST   | No        |        |
| /tas/api/visitorOptionalSearchlist/{tab}/{searchlist}                        | GET    | No        |        |
| /tas/api/visitorOptionalSearchlist/{tab}/{searchlist}                        | POST   | No        |        |
| /tas/api/visitorOptionalSearchlist/{tab}/{searchlist}/{identifier}           | PATCH  | No        |        |
| /tas/api/visitorOptionalSearchlist/{tab}/{searchlist}/{identifier}/archive   | POST   | No        |        |
| /tas/api/visitorOptionalSearchlist/{tab}/{searchlist}/{identifier}/unarchive | POST   | No        |        |

# Supporting Files API

## Avatars
| Endpoint                       | Method | Completed | cmdlet |
| ------------------------------ | ------ | --------- | ------ |
| /tas/api/avatars/operator/{id} | GET    | No        |        |
| /tas/api/avatars/person/{id}   | GET    | No        |        |

## Branches
| Endpoint                                                      | Method | Completed | cmdlet              |
| ------------------------------------------------------------- | ------ | --------- | ------------------- |
| /tas/api/branches                                             | GET    | Yes       | Get-TopdeskBranches |
| /tas/api/branches                                             | POST   | No        |                     |
| /tas/api/branches/buildingLevels                              | GET    | No        |                     |
| /tas/api/branches/designations                                | GET    | No        |                     |
| /tas/api/branches/energyPerformances                          | GET    | No        |                     |
| /tas/api/branches/environmentalImpacts                        | GET    | No        |                     |
| /tas/api/branches/free_fields/{tab}/searchlists/{searchlist}  | GET    | No        |                     |
| /tas/api/branches/id/{id}                                     | GET    | Yes       | Get-TopdeskBranches |
| /tas/api/branches/id/{id}                                     | PUT    | No        |                     |
| /tas/api/branches/id/{id}                                     | PATCH  | No        |                     |
| /tas/api/branches/id/{id}/archive                             | PUT    | No        |                     |
| /tas/api/branches/id/{id}/archive                             | PATCH  | No        |                     |
| /tas/api/branches/id/{id}/attachments                         | GET    | No        |                     |
| /tas/api/branches/id/{id}/attachments                         | POST   | No        |                     |
| /tas/api/branches/id/{id}/attachments/{attachmentId}          | DELETE | No        |                     |
| /tas/api/branches/id/{id}/attachments/{attachmentId}/download | GET    | No        |                     |
| /tas/api/branches/id/{id}/unarchive                           | PUT    | No        |                     |
| /tas/api/branches/id/{id}/unarchive                           | PATCH  | No        |                     |
| /tas/api/branches/listedBuildings                             | GET    | No        |                     |
| /tas/api/branches/lookup                                      | GET    | No        |                     |
| /tas/api/branches/lookup/{id}                                 | GET    | No        |                     |

## Budget holders
| Endpoint               | Method | Completed | cmdlet |
| ---------------------- | ------ | --------- | ------ |
| /tas/api/budgetholders | GET    | No        |        |
| /tas/api/budgetholders | POST   | No        |        |

## Countries
| Endpoint           | Method | Completed | cmdlet |
| ------------------ | ------ | --------- | ------ |
| /tas/api/countries | GET    | No        |        |

## Departments
| Endpoint             | Method | Completed | cmdlet |
| -------------------- | ------ | --------- | ------ |
| /tas/api/departments | GET    | No        |        |
| /tas/api/departments | POST   | No        |        |

## Languages
| Endpoint           | Method | Completed | cmdlet               |
| ------------------ | ------ | --------- | -------------------- |
| /tas/api/languages | GET    | Yes       | Get-TopdeskLanguages |

## Locations
| Endpoint                                                      | Method | Completed | cmdlet |
| ------------------------------------------------------------- | ------ | --------- | ------ |
| /tas/api/locations                                            | GET    | No        |        |
| /tas/api/locations                                            | POST   | No        |        |
| /tas/api/locations/building_zones                             | GET    | No        |        |
| /tas/api/locations/ceiling_coverings                          | GET    | No        |        |
| /tas/api/locations/floor_coverings                            | GET    | No        |        |
| /tas/api/locations/free_fields/{tab}/searchlists/{searchlist} | GET    | No        |        |
| /tas/api/locations/functional_uses                            | GET    | No        |        |
| /tas/api/locations/glass_materials                            | GET    | No        |        |
| /tas/api/locations/id/{id}                                    | GET    | No        |        |
| /tas/api/locations/id/{id}                                    | PUT    | No        |        |
| /tas/api/locations/id/{id}                                    | PATCH  | No        |        |
| /tas/api/locations/id/{id}/archive                            | PUT    | No        |        |
| /tas/api/locations/id/{id}/archive                            | PATCH  | No        |        |
| /tas/api/locations/id/{id}/unarchive                          | PUT    | No        |        |
| /tas/api/locations/id/{id}/unarchive                          | PATCH  | No        |        |
| /tas/api/locations/lookup                                     | GET    | No        |        |
| /tas/api/locations/lookup/{id}                                | GET    | No        |        |
| /tas/api/locations/statuses                                   | GET    | No        |        |
| /tas/api/locations/types                                      | GET    | No        |        |
| /tas/api/locations/wall_coverings                             | GET    | No        |        |

## Operator groups
| Endpoint                                  | Method | Completed | cmdlet                    |
| ----------------------------------------- | ------ | --------- | ------------------------- |
| /tas/api/operatorgroups                   | GET    | Yes       | Get-TopdeskOperatorGroups |
| /tas/api/operatorgroups                   | POST   | No        |                           |
| /tas/api/operatorgroups/id/{id}           | GET    | Yes       | Get-TopdeskOperatorGroups |
| /tas/api/operatorgroups/id/{id}           | PUT    | No        |                           |
| /tas/api/operatorgroups/id/{id}           | PATCH  | No        |                           |
| /tas/api/operatorgroups/id/{id}/archive   | PUT    | No        |                           |
| /tas/api/operatorgroups/id/{id}/archive   | PATCH  | No        |                           |
| /tas/api/operatorgroups/id/{id}/operators | GET    | No        |                           |
| /tas/api/operatorgroups/id/{id}/unarchive | PUT    | No        |                           |
| /tas/api/operatorgroups/id/{id}/unarchive | PATCH  | No        |                           |
| /tas/api/operatorgroups/lookup            | GET    | No        |                           |
| /tas/api/operatorgroups/lookup/{id}       | GET    | No        |                           |

## Operators
| Endpoint                                                      | Method | Completed | cmdlet               |
| ------------------------------------------------------------- | ------ | --------- | -------------------- |
| /tas/api/operators                                            | GET    | Yes       | Get-TopdeskOperators |
| /tas/api/operators                                            | POST   | No        |                      |
| /tas/api/operators/current                                    | GET    | No        |                      |
| /tas/api/operators/current/id                                 | GET    | No        |                      |
| /tas/api/operators/current/settings                           | GET    | No        |                      |
| /tas/api/operators/filters/branch                             | GET    | No        |                      |
| /tas/api/operators/filters/category                           | GET    | No        |                      |
| /tas/api/operators/filters/operator                           | GET    | No        |                      |
| /tas/api/operators/free_fields/{tab}/searchlists/{searchlist} | GET    | No        |                      |
| /tas/api/operators/free_fields/{tab}/searchlists/{searchlist} | POST   | No        |                      |
| /tas/api/operators/id/{id}                                    | GET    | No        |                      |
| /tas/api/operators/id/{id}                                    | PUT    | No        |                      |
| /tas/api/operators/id/{id}                                    | PATCH  | No        |                      |
| /tas/api/operators/id/{id}/archive                            | PUT    | No        |                      |
| /tas/api/operators/id/{id}/archive                            | PATCH  | No        |                      |
| /tas/api/operators/id/{id}/filters/branch                     | GET    | No        |                      |
| /tas/api/operators/id/{id}/filters/branch                     | POST   | No        |                      |
| /tas/api/operators/id/{id}/filters/branch                     | DELETE | No        |                      |
| /tas/api/operators/id/{id}/filters/category                   | GET    | No        |                      |
| /tas/api/operators/id/{id}/filters/category                   | POST   | No        |                      |
| /tas/api/operators/id/{id}/filters/category                   | DELETE | No        |                      |
| /tas/api/operators/id/{id}/filters/operator                   | GET    | No        |                      |
| /tas/api/operators/id/{id}/filters/operator                   | POST   | No        |                      |
| /tas/api/operators/id/{id}/filters/operator                   | DELETE | No        |                      |
| /tas/api/operators/id/{id}/operatorgroups                     | GET    | No        |                      |
| /tas/api/operators/id/{id}/operatorgroups                     | POST   | No        |                      |
| /tas/api/operators/id/{id}/operatorgroups                     | DELETE | No        |                      |
| /tas/api/operators/id/{id}/permissiongroups                   | GET    | No        |                      |
| /tas/api/operators/id/{id}/permissiongroups                   | POST   | No        |                      |
| /tas/api/operators/id/{id}/permissiongroups                   | DELETE | No        |                      |
| /tas/api/operators/id/{id}/unarchive                          | PUT    | No        |                      |
| /tas/api/operators/id/{id}/unarchive                          | PATCH  | No        |                      |
| /tas/api/operators/lookup                                     | GET    | No        |                      |
| /tas/api/operators/lookup/{id}                                | GET    | No        |                      |

## Permission groups
| Endpoint                  | Method | Completed | cmdlet |
| ------------------------- | ------ | --------- | ------ |
| /tas/api/permissiongroups | GET    | No        |        |

## Person Extra Fields
| Endpoint                          | Method | Completed | cmdlet |
| --------------------------------- | ------ | --------- | ------ |
| /tas/api/personExtraFieldAEntries | GET    | No        |        |
| /tas/api/personExtraFieldAEntries | POST   | No        |        |
| /tas/api/personExtraFieldBEntries | GET    | No        |        |
| /tas/api/personExtraFieldBEntries | POST   | No        |        |

## Person groups
| Endpoint                          | Method | Completed | cmdlet |
| --------------------------------- | ------ | --------- | ------ |
| /tas/api/persongroups             | GET    | No        |        |
| /tas/api/persongroups/id/{id}     | GET    | No        |        |
| /tas/api/persongroups/lookup      | GET    | No        |        |
| /tas/api/persongroups/lookup/{id} | GET    | No        |        |

## Persons
| Endpoint                                                    | Method | Completed | cmdlet                           |
| ----------------------------------------------------------- | ------ | --------- | -------------------------------- |
| /tas/api/persons                                            | GET    | Yes       | Get-TopdeskPersons               |
| /tas/api/persons                                            | POST   | No        |                                  |
| /tas/api/persons/count                                      | GET    | Yes       | Get-TopdeskPersonsCount          |
| /tas/api/persons/free_fields/{tab}/searchlists/{searchlist} | GET    | Yes       | Get-TopdeskPersonsSearchList     |
| /tas/api/persons/free_fields/{tab}/searchlists/{searchlist} | POST   | No        |                                  |
| /tas/api/persons/id/{id}                                    | GET    | Yes       | Get-TopdeskPersons               |
| /tas/api/persons/id/{id}                                    | PUT    | No        | Set-TopdeskPersons               |
| /tas/api/persons/id/{id}                                    | PATCH  | No        | Set-TopdeskPersons               |
| /tas/api/persons/id/{id}/archive                            | PUT    | Yes       | Set-TopdeskPersonArchive         |
| /tas/api/persons/id/{id}/archive                            | PATCH  | Yes       | Set-TopdeskPersonArchive         |
| /tas/api/persons/id/{id}/avatar                             | GET    | Yes       | Get-TopdeskPersonsAvatar         |
| /tas/api/persons/id/{id}/contract                           | GET    | Yes       | Get-TopdeskPersonsContract       |
| /tas/api/persons/id/{id}/contract                           | PUT    | Yes       | Set-TopdeskPersonsContract       |
| /tas/api/persons/id/{id}/contract                           | PATCH  | Yes       | Set-TopdeskPersonsContract       |
| /tas/api/persons/id/{id}/privateDetails                     | GET    | Yes       | Get-TopdeskPersonsPrivateDetails |
| /tas/api/persons/id/{id}/privateDetails                     | PUT    | Yes       | Set-TopdeskPersonsPrivateDetails |
| /tas/api/persons/id/{id}/privateDetails                     | PATCH  | Yes       | Set-TopdeskPersonsPrivateDetails |
| /tas/api/persons/id/{id}/unarchive                          | PUT    | Yes       | Set-TopdeskPersonUnArchive       |
| /tas/api/persons/id/{id}/unarchive                          | PATCH  | Yes       | Set-TopdeskPersonUnArchive       |
| /tas/api/persons/lookup                                     | GET    | Yes       | Get-TopdeskPersonsLookup         |
| /tas/api/persons/lookup/{id}                                | GET    | Yes       | Get-TopdeskPersonsLookup         |

## Pictures
| Endpoint              | Method | Completed | cmdlet |
| --------------------- | ------ | --------- | ------ |
| /tas/api/picture      | POST   | No        |        |
| /tas/api/picture/{id} | GET    | No        |        |

## Supplier contacts
| Endpoint                       | Method | Completed | cmdlet                      |
| ------------------------------ | ------ | --------- | --------------------------- |
| /tas/api/supplierContacts      | GET    | Yes       | Get-TopdeskSupplierContacts |
| /tas/api/supplierContacts/{id} | GET    | Yes       | Get-TopdeskSupplierContacts |

## Suppliers
| Endpoint                       | Method | Completed | cmdlet                     |
| ------------------------------ | ------ | --------- | -------------------------- |
| /tas/api/suppliers             | GET    | Yes       | Get-TopdeskSuppliers       |
| /tas/api/suppliers/lookup      | GET    | Yes       | Get-TopdeskSuppliersLookup |
| /tas/api/suppliers/lookup/{id} | GET    | Yes       | Get-TopdeskSuppliersLookup |
| /tas/api/suppliers/{id}        | GET    | Yes       | Get-TopdeskSuppliers       |

# Access roles API

## Roles
| Endpoint                         | Method | Completed | cmdlet           |
| -------------------------------- | ------ | --------- | ---------------- |
| /services/permissions/roles      | GET    | Yes       | Get-TopdeskRoles |
| /services/permissions/roles/{id} | GEt    | Yes       | Get-TopdeskRoles |

## RoleConfigurations
| Endpoint                                      | Method | Completed | cmdlet                        |
| --------------------------------------------- | ------ | --------- | ----------------------------- |
| /services/permissions/roleConfigurations      | GET    | Yes       | Get-TopdeskRoleConfigurations |
| /services/permissions/roleConfigurations/{id} | GET    | Yes       | Get-TopdeskRoleConfigurations |

# Task Notifications API (Labs)

## Task Notifications

| Endpoint                          | Method | Completed | cmdlet                      |
| --------------------------------- | ------ | --------- | --------------------------- |
| /tas/api/tasknotifications/custom | POST   | Yes       | New-TopdeskTaskNotification |

# Settings API

## Currency
| Endpoint          | Method | Completed | cmdlet              |
| ----------------- | ------ | --------- | ------------------- |
| /tas/api/currency | GET    | Yes       | Get-TopdeskCurrency |

# Custom Action Support API

## Sending Emails
| Endpoint                    | Method | Completed | cmdlet            |
| --------------------------- | ------ | --------- | ----------------- |
| /services/email-v1/api/send | POST   | Yes*      | Send-TopdeskEmail |

* No attacment support currently

## PDF Generation
| Endpoint                                | Method | Completed | cmdlet               |
| --------------------------------------- | ------ | --------- | -------------------- |
| /services/pdf-generator-v1/convert/html | POST   | Yes       | New-TopdeskHTMLtoPDF |

## Barcode Generation
| Endpoint                              | Method | Completed | cmdlet        |
| ------------------------------------- | ------ | --------- | ------------- |
| /solutions/multi-barcode-creator-1/qr | POST   | Yes       | New-TopdeskQR |

## Triggering Webhooks
| Endpoint                                          | Method | Completed | cmdlet |
| ------------------------------------------------- | ------ | --------- | ------ |
| /services/action-v1/api/webhooks/{urlPathSegment} | POST   | No        |        |

