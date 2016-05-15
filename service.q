\T 10
LB:0;
P:.Q.opt .z.x;

quote:([]date:10#.z.D-1;sym:10#`FDP;time:09:30t+00:30t*til 10;bid:100.+0.01*til 10;ask:101.+0.01*til 10); 

trade:([]date:10#.z.D-1;sym:10#`FDP;time:09:30t+00:30t*til 10;price:100.+0.01*til 10;size:10#100);

manageConn:{@[{NLB::neg LB::hopen x};`:localhost:1234;{show "Can't connect to Load Balancer-> ",x}]};

serviceName:$[`name in key P;`$first P`name;`EQUITY_MARKET_RDB];

serviceDetails:(`registerResource; 
  serviceName;
  `$":" sv string (();.z.h;system"p"));

execRequest:{[nh;rq]nh(`returnRes;(rq 0;@[value;rq 1;{x}]));nh[]};

queryService:{
  errProj:{[nh;sq;er]nh(sq;`$er);nh[]};
  @[execRequest[neg .z.w];x;errProj[neg .z.w;x 0]];
  NLB(`returnService;serviceName)};

.z.ts:{manageConn[];if[0<LB;@[NLB;serviceDetails;{show x}];value"\\t 0"]};

.z.pc:{[handle]if[handle~LB;LB::0;value"\\t 10000"]};
	
.z.ts[];

