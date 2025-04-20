import os
import sys
import queue
import platform
import threading
import subprocess

PATH = sys.argv[1]
PLATFORM = platform.system()

ON_POSIX = 'posix' in sys.builtin_module_names

def enqueue_output(out, queue):
    for line in out:
        queue.put(line)

def write_and_read(p, q, cmd, stop_keyword='bestmove'):
    p.stdin.write((cmd + '\n').encode("ascii"))
    p.stdin.flush()

    output = []
    while True:
        try:
            line = q.get(timeout=1)
            decoded = line.decode('utf-8').strip()
            output.append(decoded)
            if stop_keyword in decoded or stop_keyword == -1:
                break
        except queue.Empty:
            output.append('Empty error')
            break
    return '\n'.join(output)

def help():
    return "Usage : interface.py <option>\n\nOptions :\n    new          - Create a new game in starting position\n    rm <n>       - Cancel last n moves\n    moves <list> - Add the list to the moves done\n    go <n>       - AI play the best move with n level of prediction (default 10)\n\n    pers <fen> <w/b> <roque> <en-passant> <demi-coup> <tour>  - Gives a personnalized starting pos (Ex: pers k7/8/2p3r1/8/8/8/2B3P1/7K w - - 0 1)"

if PLATFORM == 'Linux':
    p = subprocess.Popen([PATH+'../stock-fish/stockfish_lin/stockfish-ubuntu-x86-64-avx2'], shell = False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, close_fds=ON_POSIX)
elif PLATFORM == 'Windows':
    p = subprocess.Popen([PATH+'../stock-fish/stockfish_win/stockfish-windows-x86-64-avx2.exe'], shell = False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, close_fds=ON_POSIX)
else:
    print('Work in developpment')
    sys.exit()

q = queue.Queue()
t = threading.Thread(target=enqueue_output, args=(p.stdout, q))
t.daemon = True
t.start()
uciok = write_and_read(p, q, 'uci', 'uciok').split('\n')[-1]
if uciok != 'uciok':
    print('uci not ok')
    sys.exit()

try: sys.argv[2]
except: 
    print(help())
    sys.exit()

if sys.argv[2] == 'new':
    write_and_read(p, q, 'position startpos', stop_keyword=-1)
    with open('track_pos.txt', 'w') as f:
        f.write('position startpos')
    with open('track_pos.txt', 'r') as f:
        print(f.read())

elif sys.argv[2] == 'rm':
    with open('track_pos.txt', 'r') as f:
        pos = f.read()
    psplit = pos.split()
    if len(psplit) == 2 or (psplit[1] == 'fen' and len(psplit) == 8):
        print('nothing to remove')
        sys.exit()
    with open('track_pos.txt', 'w') as f:
        if int(sys.argv[3]) != 0:
            f.write(' '.join(psplit[0:0-int(sys.argv[3])]))
        else:
            f.write(' '.join(psplit))
    with open('track_pos.txt', 'r') as f:
        print(f.read())

elif sys.argv[2] == 'moves':
    with open('track_pos.txt', 'r') as f:
        pos = f.read()
    psplit = pos.split()
    with open('track_pos.txt', 'a') as f:
        if len(psplit) == 2 or (psplit[1] == 'fen' and len(psplit) == 8):
            f.write(' moves')
        for m in sys.argv[3:]:
            f.write(' ' + m)
    with open('track_pos.txt', 'r') as f:
        print(f.read())

elif sys.argv[2] == 'go':
    with open('track_pos.txt', 'r') as f:
        pos = f.read()
    psplit = pos.split()
    write_and_read(p, q, pos, -1)
    try:
        depth = sys.argv[3]
    except:
        depth = '10'
    best = write_and_read(p, q, 'go depth ' + depth)
    if best.endswith('Empty error'):
        print('Empty error')
        sys.exit()
    with open('track_pos.txt', 'a') as f:
        if len(psplit) == 2 or (psplit[1] == 'fen' and len(psplit) == 8):
            f.write(' moves')
        f.write(' ' + best.split('\n')[-1].split()[1])
    print(best.split('\n')[-1].split()[1])

elif sys.argv[2] == 'pers':
    with open('track_pos.txt', 'w') as f:
        f.write('position fen ' + ' '.join(sys.argv[3:]))
    with open('track_pos.txt', 'r') as f:
        write_and_read(p, q, f.read(), 'core dumped')
        print(f.read())

else:
    print(help())