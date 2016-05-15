monitor:();
addMonitor:{[].[`monitor;();,;neg .z.w]};

services:([handle:`int$()]address:`$();source:`$();gwHandle:`int$();sq:`int$();udt:`datetime$());

serviceQueue:([gwHandle:`int$();sq:`int$()]source:`$();time:"Z"$());

gateways:();

registerGW:{gateways,:.z.w ;
	if[count monitor;@[;(`newGateway;.z.w)]each monitor];
	select source, address from services};

registerClient:{[c]if[count monitor;@[;(`newClient;c;.z.w)]each monitor];}

registerResource:{[name;addr]
  `services upsert (.z.w;addr;name;0N;0N;.z.z);
  if[count monitor;@[;(`serviceUpdate;name;.z.w)]each monitor];
  (neg gateways)@\:(`addResource;enlist`source`address!(name;addr));
  // Sends resource information to all registered gateway handles 
  serviceAvailable[.z.w;name]};

sendService:{[gw;h]neg[gw]raze(`serviceAlloc;services[h;`sq`address]);
	if[count monitor;@[;(`query;gw;h)]each monitor];};
  // Returns query sequence number and resource address to gateway handle

requestService:{[seq;serv]
  res:exec first handle from services where source=serv,null gwHandle;
  // Check if any idle service resources are available
  $[null res;
    addRequestToQueue[seq;serv;.z.w];
    [services[res;`gwHandle`sq`udt]:(.z.w;seq;.z.z);
     sendService[.z.w;res]]]};

addRequestToQueue:{[seq;serv;gw]`serviceQueue upsert  (gw;seq;serv;.z.z)};

returnService:{
  serviceAvailable . $[.z.w in (0!services)`handle;
  (.z.w;x);
  value first select handle,source from services where gwHandle=.z.w,sq=x]
 }

serviceAvailable:{[zw;serv]
  nxt:first n:select gwHandle,sq from serviceQueue where source=serv;
  serviceQueue::(1#n)_ serviceQueue;
  // Take first request for service and remove from queue
  oldGW:services[zw;`gwHandle];
  services[zw;`gwHandle`sq`udt]:(nxt`gwHandle;nxt`sq;.z.z);
  if[count monitor;@[;(`queryComplete;oldGW;zw)]each monitor];
  if[count n;sendService[nxt`gwHandle;zw]]};

.z.pc:{[h]
  services _:h;
  gateways::gateways except h;
  delete from `serviceQueue where gwHandle=h;
  monitor::monitor except neg h;
  if[count monitor;@[;(`discon;h)]each monitor];
  update gwHandle:0N from `services where gwHandle=h
 };


