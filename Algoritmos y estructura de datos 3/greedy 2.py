# -*- coding: utf-8 -*-

def cantAp(l,e):
    res = 0
    for i in range(len(l)):
        if l[i] == e:
            res += 1
    return res

def monocarp(a,b):
    if a == b:
        return 0
    elif (cantAp(a,"a") + cantAp(b,"a")) % 2 != 0:
        return -1
    else:
        dist = []
        res = []
        for i in range(len(a)):
            if a[i] != b[i]:
                dist.append(i)
        dist1 = []
        dist2 = []
        inicio = a[dist[0]]
        for j in range(len(dist)):
            if a[dist[j]] != inicio:
                dist2.append(dist[j])
            else:
                dist1.append(dist[j])
        for k in range(0,len(dist2)-1,2):
            res.append((dist2[k]+1,dist2[k+1]+1))
        for l in range(0,len(dist1)-1,2):
            res.append((dist1[l]+1,dist1[l+1]+1))
        if len(dist2) % 2 != 0:
            ma = max(dist2[-1],dist1[-1])
            mi = min(dist2[-1],dist1[-1])
            res.append((ma+1,ma+1))
            res.append((ma+1,mi+1))
    return res

input()
a = input()
b = input()
res = monocarp(a,b)
if res == -1 or res == 0:
    print(res)
else:
    print(len(res))
    for tupla in res:
        print(*tupla)