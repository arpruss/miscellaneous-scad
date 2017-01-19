#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <time.h>
#include <assert.h>

int N;
double minD = -1;
double bestSoFar = 0;

typedef struct {
    double x,y,z;
} vec3;
vec3* v;
vec3* best;

double distance(vec3* v1,vec3* v2) {
    double dx = v1->x-v2->x;
    double dy = v1->y-v2->y;
    double dz = v1->z-v2->z;
    return sqrt(dx*dx+dy*dy+dz*dz);
}

void update(double delta,double p) {
    int i,j;
    vec3* deltaV = malloc(sizeof(vec3)*N);
    assert(deltaV != NULL);
    double d,factor;
    for (i=0;i<N;i++) {
        deltaV[i].x = deltaV[i].y = deltaV[i].z = 0;
        for (j=0;j<N;j++) {
            if (i==j)
                continue;
            d = distance(&v[i],&v[j]);
            if (d == 0) {
                deltaV[i].x += (rand()/(double)(RAND_MAX+1) - 0.5) * 0.001;
                fprintf(stderr, "Collision %d %d: %.9f %.9f %.9f\n", i,j,v[i].x,v[i].y,v[i].z);
                continue;
            }
            factor = 1. / pow(d,p+1);
            deltaV[i].x += factor * (v[i].x - v[j].x);
            deltaV[i].y += factor * (v[i].y - v[j].y);
            deltaV[i].z += factor * (v[i].z - v[j].z);
        }
    }
    for (i=0;i<N;i++) {
        v[i].x += delta * 2 * p * deltaV[i].x;
        v[i].y += delta * 2 * p * deltaV[i].y;
        v[i].z += delta * 2 * p * deltaV[i].z;
        factor = 1. / sqrt(v[i].x*v[i].x + v[i].y*v[i].y + v[i].z*v[i].z);
        v[i].x *= factor;
        v[i].y *= factor;
        v[i].z *= factor;        
    }

    minD = 2;
    for (i=0;i<N;i++) {
        for (j=i+1;j<N;j++) {
            d = distance(&v[i],&v[j]);
            if (d < minD) minD = d;
        }
    }
    free(deltaV);
    fprintf(stderr, "%.9f [p=%.9f]\n", minD, p);
}

int
main(int argc, char** argv) {
    int nIter;
    int repeats = 1;
    assert(argc >= 3);
    N = atoi(argv[1]);
    nIter = atoi(argv[2]);
    if (argc >= 4) 
       repeats = atoi(argv[3]);
    v = malloc(sizeof(vec3)*N);
    assert(v != NULL);
    best = malloc(sizeof(vec3)*N);
    assert(best != NULL);
    srand(time(0));
    vec3 origin;
    origin.x = origin.y = origin.z = 0.;
    int i;
    
    while (repeats-- > 0) {
        for (i=0;i<N;i++) {
            do {
                v[i].x = 1-2*rand() / (RAND_MAX+1.);
                v[i].y = 1-2*rand() / (RAND_MAX+1.);
                v[i].z = 1-2*rand() / (RAND_MAX+1.);
            } while (distance(&v[i],&origin) >= 1);
        }
        
        for (i=0;i<nIter;i++) {
            double p = 1+i*(4.-1)/nIter;
            update(.75*pow(minD,p)/N, p); // 0.0005/N,p); 
            if (minD > bestSoFar) {
                int j;
                for(j=0;j<N;j++) {
                    best[j] = v[j];
                }
                bestSoFar = minD;
            }
        }
        fprintf(stderr,"%.9f [%.9f]\n",minD,bestSoFar);
    }
    
    printf("n=%d;\nminD=%.9f;\n", N, bestSoFar);
    printf("points = [");
    for(i=0;i<N;i++) {
        printf("[%.9f,%.9f,%.9f]", best[i].x, best[i].y, best[i].z);
        if (i+1 < N) putchar(',');
    }
    printf ("];\n");
    puts("echo(len(points));\ndifference() {sphere(r=1,$fn=max([2*n,100]));\nfor(i=[0:n-1]) translate(points[i]) sphere(d=minD,$fn=12);}\n");
    free(v);
    free(best);
    
    return 0;
}
