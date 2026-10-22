# Autopilote v2 : cascade vitesse -> accel -> vecteur de poussee, modulation sigma-delta.
import math
G_BY_MISSION = None
def make_autopilot(dbg, beams, debris, step, hold, clamp, PAD_HALF=39):
    def autopilot(maxsec=150, wait=0.0):
        acc = 0.0
        ticks = 0
        while ticks < maxsec*30:
            d = dbg()
            if d['state'] != 'game': return ('state', d['state'])
            if d['landed']: return (True, d)
            if d['failed']: return (False, 'failed:'+str(d['msg']))
            x,y,vx,vy,a = d['x'],d['y'],d['vx'],d['vy'],d['angle']
            g = d['g']
            if ticks < wait*30: tx,ty,land = 80,175,False
            elif d['hascell'] and d['cargo']==0: tx,ty,land = d['cellx'],d['celly'],False
            else: tx,ty,land = d['padx'],d['pady'],True
            dx = tx-x
            # altitude de croisiere : au-dessus du terrain et de la cible
            cruise = min(ty-70, d['cruise'])
            aligned = abs(dx) < (24 if land else 12) and abs(vx) < 12
            if aligned:
                ydes = ty-12 if land else ty
            else:
                ydes = cruise
            # profil vertical : descente lente si pose
            vymax_dn = 20 if land and y > ty-70 else 55
            vydes = clamp((ydes-y)*1.1, -55, vymax_dn)
            vxdes = math.copysign(min(50, math.sqrt(2*8*abs(dx))), dx) if abs(dx) > 30 else clamp(dx*0.5, -18, 18)
            # attente devant un rayon
            for b in beams():
                bx=b['x']; ahead=(bx-x)*(1 if dx>0 else -1)
                if 0 < ahead < 70 and abs(dx) > 30:
                    u=b['u']; per=b['period']; tt_on=(per-u)%per
                    if u < b['on'] or tt_on < 1.8: vxdes = 0
            # esquive des epaves dures : monter si l'une est proche
            for e in debris():
                if not e['soft'] and abs(e['x']-x) < 70 and abs(e['y']-y) < 60 and not aligned:
                    vydes = min(vydes, -30) if e['y'] > y-10 else vydes
            ax = clamp((vxdes-vx)*1.2, -25, 25)
            ay = clamp((vydes-vy)*1.5, -60, 60)
            Tx = ax - d['wind']
            Ty = g - ay
            if Ty < 5: Ty = 5
            astar = clamp(math.atan2(Tx, Ty), -0.9, 0.9)
            if land and y > ty-60: astar = clamp(astar, -0.12, 0.12)
            hold('left', a > astar+0.03); hold('right', a < astar-0.03)
            Tmag = math.hypot(Tx, Ty)
            acc += (Tmag/105.0)
            on = False
            if abs(a-astar) < 0.35 and acc >= 1.0:
                on = True; acc -= 1.0
            elif acc > 1.0: acc = 1.0
            hold('up', on)
            step(1); ticks += 1
        return (False, 'timeout')
    return autopilot
