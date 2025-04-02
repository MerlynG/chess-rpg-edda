import sys
import subprocess
import threading
import queue

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
    return "Usage : interface.py <option>\n\nOptions :\n    new          - Create a new game in starting position\n    rm <n>       - Cancel last n moves\n    moves <list> - Add the list to the moves done\n    go <n>       - AI play the best move with n level of prediction (default 10)"

p = subprocess.Popen(['./stockfish/stockfish-ubuntu-x86-64-avx2'], shell = False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, close_fds=ON_POSIX)
q = queue.Queue()
t = threading.Thread(target=enqueue_output, args=(p.stdout, q))
t.daemon = True
t.start()
uciok = write_and_read(p, q, 'uci', 'uciok').split('\n')[-1]
if uciok != 'uciok':
    print('uci not ok')
    sys.exit()

try: sys.argv[1]
except: 
    print(help())
    sys.exit()

if sys.argv[1] == 'new':
    write_and_read(p, q, 'position startpos', stop_keyword=-1)
    with open('track_pos.txt', 'w') as f:
        f.write('position startpos')
    with open('track_pos.txt', 'r') as f:
        print(f.read())

elif sys.argv[1] == 'rm':
    with open('track_pos.txt', 'r') as f:
        pos = f.read()
    if len(pos.split()) == 2:
        print('nothing to remove')
        sys.exit()
    pos = pos.split()
    with open('track_pos.txt', 'w') as f:
        if int(sys.argv[2]) != 0:
            f.write(' '.join(pos[0:0-int(sys.argv[2])]))
        else:
            f.write(' '.join(pos))
    with open('track_pos.txt', 'r') as f:
        print(f.read())

elif sys.argv[1] == 'moves':
    with open('track_pos.txt', 'r') as f:
        pos = f.read()
    with open('track_pos.txt', 'a') as f:
        if len(pos.split()) == 2:
            f.write(' moves')
        for m in sys.argv[2:]:
            f.write(' ' + m)
    with open('track_pos.txt', 'r') as f:
        print(f.read())

elif sys.argv[1] == 'go':
    with open('track_pos.txt', 'r') as f:
        pos = f.read()
    write_and_read(p, q, pos, -1)
    try:
        depth = sys.argv[2]
    except:
        depth = '10'
    best = write_and_read(p, q, 'go depth ' + depth)
    with open('track_pos.txt', 'a') as f:
        if len(pos.split()) == 2:
            f.write(' moves')
        f.write(' ' + best.split('\n')[-1].split()[1])
    print(best.split('\n')[-1].split()[1])

else:
    print(help())