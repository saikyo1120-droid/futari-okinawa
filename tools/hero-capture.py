import threading, http.server, functools, base64, sys, time
from playwright.sync_api import sync_playwright
from PIL import Image
import io
HERE='/tmp/claude-0/-home-claude/ff301835-b08b-5693-9965-5c8731996946/scratchpad/render'
class Q(http.server.SimpleHTTPRequestHandler):
    def log_message(self,*a):pass
srv=http.server.ThreadingHTTPServer(('127.0.0.1',8790),functools.partial(Q,directory=HERE))
threading.Thread(target=srv.serve_forever,daemon=True).start()
size=int(sys.argv[1]) if len(sys.argv)>1 else 800
layers=sys.argv[2].split(',') if len(sys.argv)>2 else ['all']
with sync_playwright() as p:
    b=p.chromium.launch(args=["--use-gl=angle","--use-angle=swiftshader","--enable-unsafe-swiftshader","--ignore-gpu-blocklist"])
    pg=b.new_page(viewport={'width':size,'height':size})
    errs=[];pg.on('pageerror',lambda e:errs.append(str(e)));pg.on('console',lambda m: errs.append(m.text) if m.type=='error' else None)
    pg.goto(f'http://127.0.0.1:8790/scene.html?size={size}')
    pg.wait_for_function('window.ready===true',timeout=120000)
    for name in layers:
        t0=time.time()
        data=pg.evaluate(f"window.renderLayer('{name}')")
        img=Image.open(io.BytesIO(base64.b64decode(data.split(',')[1])))
        img.save(f'{HERE}/out_{name}.png');print(name,img.size,'%.1fs'%(time.time()-t0))
    print('errors',errs)
    b.close()
srv.shutdown()
