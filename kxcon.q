\p 1235
fnt:();
h:hopen`::1234;
P:.Q.opt .z.x;
lg:$[`log in key P;{show x};{::}];
PORT:4000;

h"addMonitor[]";

services:enlist `id`label`group!(0;`$"Load Balancer";0);

.[`services;();,;flip`id`label`group!flip{(x;`$"gw-",string x;1)}'[h"gateways"]];
.[`services;();,;ungroup `label`id`group xcol update x:i+3 from `source xgroup h"select handle,source from services"];

GRP:(!). services[`label`group];
links:([]from:();to:();id:());

createLinks:{[].[`links;();,;]update id:{$[count links;max links`id;0]+x}[i] from flip `from`to!flip 0 cross exec id from services where not label in `$("Load Balancer";"user");`links set distinct links};

createLinks[];

newGateway:{[id]lg"New Gateway";
	s:enlist `id`label`group!(id;`$(string last gateways`name);1);.[`services;();,;s];
	.[`links;();,;l:update id:(?[0<count links;1+max links`id;0]) from enlist `from`to!(0;id)];
	newUpdate[`addNode;s;l];newUpdate[`link;s;l]};

newClient:{[c;h]
	ids:0N!?[links;((=;`from;h);(<;`to;0));0b;()];
	if[count ids;newUpdate[`rmlink;services;ids];`links set links except ids];
	node:select from services where id in (ids`to),not id=0;
	if[count node;newUpdate[`rmNode;node;links];`services set services except node];
	if[c>0;
		.[`services;();,;s:flip `id`label`group!(n:(min services`id)+neg 1+til c;c#`user;c#2)];
		.[`links;();,;l:update id:((1+max links`id)+til count m) from flip `from`to!flip m:h cross n]];
	show"Here.";0N!s;0N!l;	
	newUpdate[`addNode;s;l];newUpdate[`link;s;l];
	};
	
serviceUpdate:{lg"serviceUpdate";
	.[`services;();,;s:enlist `id`label`group!(y;x;$[null g:GRP[x];
		[GRP[x]:(g:$[3>m:max GRP;3;m+1]);g];
		g])];
	.[`links;();,;l:update id:(?[0<count links;1+max links`id;0]) from enlist `from`to!(0;y)];
	l:?[links;((|;(=;`from;y);(=;`to;y));(%HOMEPATH%:;(=;`from;(:':;`to))));0b;()];
	newUpdate[`addNode;s;l]};

addQueue:{[x]lg"serviceQueueUpdate";lg x};

query:{[x;y]lg"New Query";.[`links;();,;l:enlist `id`from`to!((1+max links`id);x;y)];newUpdate[`link;services;l,'enlist(`dashes`arrows)!`true`to]};

queryComplete:{[x;y]if[not null x;
	lg"Query Complete";
	l:?[links;((=;`from;x);(=;`to;y));0b;()];`links set links except l;newUpdate[`rmlink;services;l]]};

discon:{[h]lg"Service Disconnected";s:select from services where id=h;`services set services except s;createLinks[];newUpdate[`rmNode;s;links]};

.z.pc:{[x]lg"Disconnected from Load Balancer";if[h=x;delete from `services]};

gateways:([]name:();port:());

.z.ws:{[x]show x;request:("*****";" ")0:x;$[x like "";
	[show"Adding Monitor: ",string s:neg .z.w;.[`fnt;();,;s];s .j.j `action`service`link!(`init;services;links)];
	`Service=`$request[0];
	[PORT::max pn:1+PORT+til "I"$request[2];show"Starting Services";system each (("q %HOMEPATH%/kxconscripts/service.q -name ",request[1]," -p "),/:string pn),\:" -q &"];
	`Gateway=`$request[0];
	[`gateways upsert (`$request[1];PORT+:1);show"Starting Gateway";system raze"q %HOMEPATH%/kxconscripts/gateway.q -p ",(string PORT)," -q &"];
	`Client=`$request[0];
	[p:exec port from gateways where name=`$request[1];show"Starting Client";system raze"q %HOMEPATH%/kxconscripts/client.q -gw ::",(string p)," -size ",request[3]," -service ",request[2]," -t ",request[4]," -q &"];
	`Reset=`$request[0];
	reset[];
	show"Request not valid"]};

newUpdate:{[t;s;l]
	u:((enlist`action)!enlist t),`service`link!(s;l);
	if[count fnt;{[u;h]@[h;.j.j u;{[h;e]lg"Monitor Disconnect";`fnt set fnt except h}[h]]}[u;first fnt]]}


(neg h)"@[;(`clientCount;`)]each neg gateways";

reset:{[]
	show"Resetting Plant";
	system"kill $(ps -ef | grep kxconscripts | egrep -v kxcon.q | egrep -v loadbalancer.q | grep l32arm/q | awk '{print $2}')";
	newUpdate[`rmNode;select from services where not id=0;links];
	delete from `links;delete from `services where not id=0;PORT::4000;delete from `gateways;GRP::1#GRP;
	newUpdate[`reset;services;links];
	}
