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


def dialog(process, arg):
    process.stdin.write(arg)

p = subprocess.Popen(['./stockfish/stockfish-ubuntu-x86-64-avx2'], shell = False, stdin=subprocess.PIPE, stdout=subprocess.PIPE, close_fds=ON_POSIX)
q = queue.Queue()
t = threading.Thread(target=enqueue_output, args=(p.stdout, q))
t.daemon = True
t.start()
print(write_and_read(p, q, 'uci', 'uciok').split('\n')[-1])

if sys.argv[1] == 'new':
    

# print(write_and_read(p, q, 'position startpos'))
# print(write_and_read(p, q, 'go depth 15'))