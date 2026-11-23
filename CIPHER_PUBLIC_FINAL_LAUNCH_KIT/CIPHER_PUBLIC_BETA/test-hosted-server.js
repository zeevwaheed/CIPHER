'use strict';
const {spawn}=require('child_process');
const assert=require('assert');
const path=require('path');
const port=Number(process.env.CIPHER_TEST_PORT||3187);
const env={...process.env,PORT:String(port),SUPABASE_URL:'',SUPABASE_ANON_KEY:'',OPENROUTER_API_KEY:''};
const child=spawn(process.execPath,[path.join(__dirname,'server-hosted.js')],{env,stdio:['ignore','pipe','pipe']});
let output=''; child.stdout.on('data',d=>output+=d);child.stderr.on('data',d=>output+=d);
const base=`http://127.0.0.1:${port}`;
async function wait(){for(let i=0;i<40;i++){try{await fetch(base+'/api/health');return}catch{await new Promise(r=>setTimeout(r,150));}}throw new Error('Server failed to start: '+output)}
(async()=>{try{
 await wait();
 let r=await fetch(base+'/api/health');assert.equal(r.status,200);let h=await r.json();assert.equal(h.service,'cipher');assert.equal(h.authConfigured,false);
 r=await fetch(base+'/config.js');assert.equal(r.status,200);let cfg=await r.text();assert(cfg.includes('CIPHER_RUNTIME_CONFIG'));assert(!cfg.includes('OPENROUTER_API_KEY'));
 r=await fetch(base+'/');assert.equal(r.status,200);let html=await r.text();assert(html.includes('CIPHER'));
 r=await fetch(base+'/pixel-party.mp3');assert.equal(r.status,200);assert.equal(r.headers.get('content-type'),'audio/mpeg');
 r=await fetch(base+'/api/chat',{method:'POST',headers:{'Content-Type':'application/json'},body:'{}'});assert.equal(r.status,401);
 r=await fetch(base+'/not-a-real-file');assert.equal(r.status,404);
 console.log('PASS: health, config, homepage, audio asset, unauthenticated API rejection, unknown route');
 }catch(e){console.error('FAIL:',e.stack||e);process.exitCode=1;}finally{child.kill();}})();
