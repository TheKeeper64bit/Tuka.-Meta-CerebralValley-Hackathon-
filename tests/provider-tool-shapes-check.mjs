import test from 'node:test';
import assert from 'node:assert/strict';
import {extractJourneyToolCalls,interpretJourney} from '../server/meta-intent.js';
const env={MODEL_API_KEY:'meta-test',BASETEN_API_KEY:'baseten-test',BASETEN_MODEL:'meta-models/muse-spark-open-1026'};
const intent={origin:null,destination:'Tilburg Centraal',mode:'now',date:null,time:null,maxWalkingMinutes:10,preference:'fastest'};
const req=()=>new Request('https://local/api/meta/interpret',{method:'POST',body:JSON.stringify({cityId:'tilburg',message:'Take me to Tilburg Centraal'})});
const standard=(value=intent)=>({choices:[{message:{tool_calls:[{type:'function',function:{name:'plan_transit_journey',arguments:JSON.stringify(value)}}]}}]});

test('normalizes standard Meta tool_calls with encoded arguments',()=>{
 const calls=extractJourneyToolCalls(standard());assert.equal(calls.length,1);assert.equal(calls[0].name,'plan_transit_journey');assert.deepEqual(calls[0].arguments,intent);
});
test('normalizes Baseten object arguments without accepting text',()=>{
 const calls=extractJourneyToolCalls({choices:[{message:{tool_calls:[{function:{name:'plan_transit_journey',arguments:intent}}]}}]});assert.deepEqual(calls[0].arguments,intent);
 assert.deepEqual(extractJourneyToolCalls({choices:[{message:{content:'Here is your route'}}]}),[]);
});
test('normalizes structured content blocks',()=>{
 const calls=extractJourneyToolCalls({choices:[{message:{content:[{type:'tool_use',name:'plan_transit_journey',input:intent}]}}]});assert.deepEqual(calls[0].arguments,intent);
});
test('accepts only strict JSON content as a provider fallback shape',()=>{
 assert.deepEqual(extractJourneyToolCalls({choices:[{message:{content:JSON.stringify(intent)}}]})[0].arguments,intent);
 assert.deepEqual(extractJourneyToolCalls({choices:[{message:{content:'```json\\n'+JSON.stringify(intent)+'\\n```'}}]}),[]);
});
for(const [name,providerEnv,shape] of [
 ['Meta',env,standard()],
 ['Baseten',{...env,MODEL_PROVIDER:'baseten'}, {choices:[{message:{content:JSON.stringify(intent)}}]}],
]) test(`${name} normalized intent remains schema validated`,async()=>{
 const response=await interpretJourney(req(),providerEnv,{fetcher:async(_url,init)=>{const body=JSON.parse(init.body);assert.equal(body.tool_choice,'required');return Response.json(shape)}});
 assert.equal(response.status,200);const json=await response.json();assert.equal(json.provider,name.toLowerCase());assert.deepEqual(json.intent,intent);
});
for(const shape of [
 {choices:[{message:{tool_calls:[{function:{name:'plan_transit_journey',arguments:'{"destination":"Tilburg Centraal"}'}}]}}]},
 {choices:[{message:{tool_calls:[{function:{name:'plan_transit_journey',arguments:JSON.stringify(intent)}},{function:{name:'plan_transit_journey',arguments:JSON.stringify(intent)}}]}}]},
 {choices:[{message:{content:'I can take you there.'}}]},
 {choices:[{message:{content:[{type:'text',text:JSON.stringify(intent)}]}}]},
]) test('rejects malformed, missing-argument, multiple-call, and unsupported formats',async()=>{
 const response=await interpretJourney(req(),{...env,MODEL_FALLBACK_ENABLED:'false'},{fetcher:async()=>Response.json(shape)});assert.equal(response.status,422);
});
