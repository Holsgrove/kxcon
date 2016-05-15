P:.Q.opt .z.x;

gwh:$[`gw in key P;hsym`$first P`gw;`:localhost:5555];

querySize:$[`size in key P;"system\"sleep ",(first P`size),"\";";""];
service:$[`service in key P;`$first P`service;`EQUITY_MARKET_RDB];

gw:{h:hopen x;{(neg x)(`userQuery;y);x[]}[h]}[gwh];

.z.ts:{gw(service;raze querySize,"select from quote")}
