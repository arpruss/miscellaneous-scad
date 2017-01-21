#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>

int N;
double minD = 0;
double bestMinD = 0;

typedef struct {
    double x,y,z;
} vec3;
vec3* pos;
vec3* v;
vec3* best;

double urandom() {
    return 2. * rand() / (RAND_MAX+1.) - 1.;
}

double norm(vec3* v) {
    return sqrt(v->x*v->x+v->y*v->y+v->z*v->z);
}

double distance(vec3* v1,vec3* v2) {
    double dx = v1->x-v2->x;
    double dy = v1->y-v2->y;
    double dz = v1->z-v2->z;
    return sqrt(dx*dx+dy*dy+dz*dz);
}

double distanceSq(vec3* v1,vec3* v2) {
    double dx = v1->x-v2->x;
    double dy = v1->y-v2->y;
    double dz = v1->z-v2->z;
    return dx*dx+dy*dy+dz*dz;
}

void *safemalloc(long n) {
    void* p = malloc(n);
    if (p == NULL) {
        fprintf(stderr, "Out of memory (requested %ld).\n", n);
        exit(3);
    }
    return p;
}

void calculateMinD(void) {
    double minD2 = 4;
    int i;

    int N0 = (N % 2) ? N : N/2;

    for (i=0;i<N0;i++) {
        double d2;
        int j;
        for (j=i+1;j<N;j++) {
            d2 = distanceSq(&pos[i],&pos[j]);
            if (d2 < minD2) minD2 = d2;
        }
    }
    minD = sqrt(minD2);
}

double maxMinD(vec3* pos) {
    double maxMinD2 = -1;
    int i;

    int N0 = (N % 2) ? N : N/2;

    for (i=0;i<N0;i++) {
        double minD2;
        double d2;
        int j;
        minD2 = 4;
        for (j=0;j<N;j++) {
            if (j!=i) {
                d2 = distanceSq(&pos[i],&pos[j]);
                if (d2 < minD2) minD2 = d2;
            }
        }
        if (minD2 > maxMinD2) {
            maxMinD2 = minD2;
        }
    }
    return sqrt(maxMinD2);
}

void update(double approxDx,double p,double minus,double friction) {
    int i,j;
    
    double maxV = 0;
    double thisV;
    
    int N0 = (N % 2) ? N : N/2;

    vec3* newV = safemalloc(sizeof(vec3) * N0);
    
    for (i=0;i<N0;i++) {
        thisV = norm(&v[i]);
        if (thisV > maxV)
            maxV = thisV;
    }
    
    if (maxV == 0) 
        maxV = 10;
    
    double dt = approxDx / maxV;
    if (dt * friction > 0.75) 
        dt = 0.75 / friction;

#pragma omp parallel
#pragma omp for private(i,j)
    for (i=0;i<N0;i++) {        
        double n;
        double d;
        double factor;
        newV[i].x = v[i].x * (1. - dt * friction);
        newV[i].y = v[i].y * (1. - dt * friction);
        newV[i].z = v[i].z * (1. - dt * friction);
        
        for (j=0;j<N;j++) {
            if (i==j)
                continue;
            d = distance(&pos[i],&pos[j]);
            if (d == 0) {
                newV[i].x += urandom() * 0.001 * dt;
                newV[i].y += urandom() * 0.001 * dt;
                newV[i].z += urandom() * 0.001 * dt;
                fprintf(stderr, "Collision %d %d: %.9f %.9f %.9f\n", i,j,v[i].x,v[i].y,v[i].z);
                continue;
            }
            factor = dt / pow(d-minus,p+1);
            newV[i].x += factor * (pos[i].x - pos[j].x);
            newV[i].y += factor * (pos[i].y - pos[j].y);
            newV[i].z += factor * (pos[i].z - pos[j].z);
        }
    }
    
    double n;
    for (i=0;i<N0;i++) {
        // Euler-Cromer
        pos[i].x += dt * newV[i].x / 2.;
        pos[i].y += dt * newV[i].y / 2.;
        pos[i].z += dt * newV[i].z / 2.;
        
        n = norm(&pos[i]);
        if (n==0) {
            pos[i].x=1;
            pos[i].y=0;
            pos[i].z=0;
        }
        else {
            pos[i].x /= n;
            pos[i].y /= n;
            pos[i].z /= n;
            v[i] = newV[i];
        }

        if (N0 < N) {
            pos[N0+i].x = -pos[i].x;
            pos[N0+i].y = -pos[i].y;
            pos[N0+i].z = -pos[i].z;
        }
    }
    
    calculateMinD();

    free(newV);
}

void usage(void) {
    fprintf(stderr, "tammes-newton [-animate] nPoints [nIterations [frictionMultiplier]]\n");
}

void dumpFrame(int frameCount, vec3* positions, double minD) {
    int i;
    printf("minD %.9f\n", minD);
    for(i=0;i<N;i++) 
        printf("pos %d %.9f %.9f %.9f\n", i, positions[i].x, positions[i].y, positions[i].z);
    printf("frame %d\n", frameCount);
}

int
main(int argc, char** argv) {	
	int nIter = 500;
    int repeats = 1;
    int animation = 0;
    double frictionMultiplier = 0.16;
    
    if (argc >= 2 && ! strncmp(argv[1], "-a", 2)) {
        animation = 1;
        argc--;
        argv++;
    }

    
    if (argc < 2) {
        usage();
        return 1;
    }
    
    N = atoi(argv[1]);
    if (argc >= 3) {
        nIter = atoi(argv[2]);
        if (argc >= 4) 
           frictionMultiplier = atof(argv[3]);
    }
    pos = safemalloc(sizeof(vec3)*N);
    // we waste a bit of memory when N is even, but memory is cheap
    v = safemalloc(sizeof(vec3)*N);
    best = safemalloc(sizeof(vec3)*N);
    srand(time(0));
    vec3 origin;
    origin.x = origin.y = origin.z = 0.;
    int i;
    
// impose antipodal symmetry (or almost if N is odd), using idea of https://math.mit.edu/research/highschool/rsi/documents/2012Gautam.pdf
    int N0 = (N+1)/2;
    for (i=0;i<N0;i++) {
        double n;
        do {
            pos[i].x = urandom();
            pos[i].y = urandom();
            pos[i].z = urandom();
            n = norm(&pos[i]);
        } while (n > 1 || n == 0.);
        pos[i].x /= n;
        pos[i].x /= n;
        pos[i].x /= n;
        v[i].x = 0;
        v[i].y = 0;
        v[i].z = 0;
        if (N0+i < N) {
            pos[N0+i].x = -pos[i].x;
            pos[N0+i].y = -pos[i].y;
            pos[N0+i].z = -pos[i].z;
            v[N0+i].x = 0;
            v[N0+i].y = 0;
            v[N0+i].z = 0;
        }
    }
    
    double nextShow = 0;

    calculateMinD();
    
    if (animation) {
        printf("n %d\n",N);
        dumpFrame(0,pos,minD);
    }

    for (i=0;i<nIter;i++) {
        double p = 1+i*(8.-1)/nIter;
        if (p>4.5) p=4.5;
        // 7,4.5,3,10,0 : 0.153
        double minus;
        if (p >= 1) {
            minus = 0.9 * minD * i / nIter;
        }
        else {
            minus = 0;
        }
        update(.3*minD+0.00000001, p, minus, frictionMultiplier*N); // 0.0005/N,p); 
        if (minD > bestMinD) {
            int j;
            for(j=0;j<N;j++) {
                best[j] = pos[j];
            }
            bestMinD = minD;
        }
        if ((double)i/(nIter-1) >= nextShow || i == nIter-1) {
            fprintf(stderr, "%.0f%% minD=%.5f maxMinD=%.5f bestD=%.5f bestMaxMinD=%.5f p=%.5f       \r", 100.*i/(nIter-1), minD, maxMinD(pos), bestMinD, maxMinD(best), p);
            nextShow += 0.05;
        }
        if (animation) 
            dumpFrame(i+1,pos,minD);
    }
    fprintf(stderr, "\n");

    if (animation)
        dumpFrame(nIter+1,best,bestMinD);
    
    if (!animation) {
        printf("n=%d;\nminD=%.9f;\n", N, bestMinD);
        //printf("bumpR = 2*sin((1/2)*asin(minD/2));\n");
        printf("points = [");
        for(i=0;i<N;i++) {
            printf("[%.9f,%.9f,%.9f]", best[i].x, best[i].y, best[i].z);
            if (i+1 < N) putchar(',');
        }
        printf ("];\n");
        puts("difference() {\n sphere(r=1,$fn=36);\n for(i=[0:len(points)-1]) translate(points[i]) sphere(d=minD,$fn=12);\n}\n");
    }

    free(v);
    free(best);
    free(pos);
    
    return 0;
}
