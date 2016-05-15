usr:();

manageConn:{@[{NLB::neg LB::hopen x};`:localhost:1234;{show x}]};

registerGWFunc:{addResource LB(`registerGW;`)};

resources:([address:()] source:();sh:());

addResource:{`resources upsert `address xkey update sh:{hopen first x}'[address] from x};

queryTable:([sq:`int$()];uh:`int$();rec:`datetime$();snt:`datetime$();ret:`datetime$();user:`$();sh:`int$();serv:`$();query:());

userQuery:{
  $[(serv:x 0) in exec distinct source from resources;
  // Check if valid service
    [queryTable,:(SEQ+:1;.z.w;.z.z;0Nz;0Nz;.z.u;0N;serv;x 1);
      NLB(`requestService;SEQ;serv)];
   (neg .z.w)(`$"Service Unavailable")]};

serviceAlloc:{[sq;addr]
  $[null queryTable[sq;`uh];
  // Check if user is still waiting on results
    NLB(`returnService;sq);
  // Service no longer required
    [(neg sh:resources[addr;`sh])
       (`queryService;(sq;queryTable[sq;`query]));
  // Send query to allocated resource, update queryTable
        queryTable[sq;`snt`sh]:(.z.z;sh)]]};

returnRes:{[res]
  uh:first exec uh from queryTable where sq=(res 0); 
  // (res 0) is the sequence number
  if[not null uh;(neg uh)(res 1)]; 
  // (res 1) is the result
  queryTable[(res 0);`ret]:.z.z
 };

.z.pc:{[handle]
  update uh:0N from `queryTable where uh=handle;
  delete from `resources where sh=handle;
  if[count sq:exec distinct sq from queryTable where sh=handle,null ret;
     returnRes'[sq cross `$"Database Disconnect"]];
  if[handle in usr;usr::usr except handle;NLB(`registerClient;count usr)];
  if[handle~LB;
     (neg exec uh from queryTable where not null uh,null snt)@\:
       `$"Service Unavailable";
	hclose each (0!resources)`sh;
      delete from `resources;
      update snt:.z.z,ret:.z.z from `queryTable where not null uh,null snt;
	LB::0; value"\\t 10000"]};

clientCount:{[]NLB(`registerClient;count usr)};

.z.ts:{
  manageConn[]; if[0<LB;@[registerGWFunc;`;{show x}];value"\\t 0"]
 };

.z.ts[];

.z.po:{[h]if[not h=LB;.[`usr;();,;h];clientCount[]]};

