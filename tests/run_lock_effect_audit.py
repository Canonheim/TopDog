"""Fresh process per effect/mode; never run concurrently with another Godot job."""
import argparse, json, pathlib, re, subprocess, sys
p=argparse.ArgumentParser()
p.add_argument('--repo',default=r'C:/Users/growi/Desktop/top dog')
p.add_argument('--godot',default=r'C:/Users/growi/Downloads/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe')
p.add_argument('--effects',nargs='*')
p.add_argument('--output',default='lock-effect-performance')
a=p.parse_args();r=pathlib.Path(a.repo);out=pathlib.Path(a.output);out.mkdir(exist_ok=True)
line=re.search(r'^const EFFECTS = (.+)$',(r/'core/wardrobe.gd').read_text(),re.M)
ids=a.effects or json.loads(line[1]);results=[];failed=False
for name in ids:
 for mode in ['cold','prepared']:
  command=[a.godot,'--headless','--path',str(r),'--script','res://tests/lock_effect_cost_audit.gd','--','--no-steam','--effect='+name,'--mode='+mode]
  try:
   process=subprocess.run(command,capture_output=True,text=True,timeout=45)
   log=process.stdout+'\n'+process.stderr
   found=re.search(r'LOCK_EFFECT_AUDIT_JSON (.+)',log)
   result=json.loads(found[1]) if found else {'effect':name,'mode':mode,'errors':['No audit result']}
   result['exit_code']=process.returncode
  except subprocess.TimeoutExpired as e:
   def decoded(value): return value.decode(errors='replace') if isinstance(value,bytes) else (value or '')
   log=str(e)+'\n'+decoded(e.stdout)+'\n'+decoded(e.stderr);result={'effect':name,'mode':mode,'errors':['Process timed out']}
  (out/(name+'-'+mode+'.log')).write_text(log)
  results.append(result);failed|=bool(result.get('errors'))
  (out/'results.json').write_text(json.dumps(results,indent=2))
  print(name,mode,'first_ms',result.get('first_process_burst_cpu_ms'),'max_ms',result.get('max_cpu_ms'),'prep_step',result.get('prepare_max_step_ms'),'errors',result.get('errors'),flush=True)
sys.exit(1 if failed else 0)
