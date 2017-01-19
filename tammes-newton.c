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
vec3* pos;
vec3* v;
vec3* best;

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

void update(double approxDx,double p,double friction,int vIndepFriction) {
    int i,j;
    
    double maxV = 0;
    double thisV;
    
    int N0 = (N % 2) ? N : N/2;

    vec3* newV = malloc(sizeof(vec3) * N0);
    
    for (i=0;i<N0;i++) {
        thisV = norm(&v[i]);
        if (thisV > maxV)
            maxV = thisV;
    }
    
    if (maxV == 0) 
        maxV = 10;
    
    double dt = approxDx / maxV;
    if (!vIndepFriction) {
        if (dt * friction > 0.75) 
            dt = 0.75 / friction;
    }
    else {
        for(i=0;i<N0;i++) {
            double n;
            n = norm(&v[i]);
            if (dt * friction > 0.75 * n)
                dt = 0.75 * n / friction;
        }
    }

#pragma omp parallel 
#pragma omp for private(i,j)
    for (i=0;i<N0;i++) {        
        vec3 normalizedV;
        double n;
        double d;
        double factor;
        normalizedV = v[i];
        n = norm(&normalizedV);
        
        if (n != 0 && vIndepFriction) {
            normalizedV.x /= n;
            normalizedV.y /= n;
            normalizedV.z /= n;
        }
        
        newV[i].x = v[i].x - dt * friction * normalizedV.x;
        newV[i].y = v[i].y - dt * friction * normalizedV.y;
        newV[i].z = v[i].z - dt * friction * normalizedV.z;
        
        for (j=0;j<N;j++) {
            if (i==j)
                continue;
            d = distance(&pos[i],&pos[j]);
            if (d == 0) {
                newV[i].x += (rand()/(double)(RAND_MAX+1.) - 0.5) * 0.001 * dt;
                newV[i].y += (rand()/(double)(RAND_MAX+1.) - 0.5) * 0.001 * dt;
                newV[i].z += (rand()/(double)(RAND_MAX+1.) - 0.5) * 0.001 * dt;
                fprintf(stderr, "Collision %d %d: %.9f %.9f %.9f\n", i,j,v[i].x,v[i].y,v[i].z);
                continue;
            }
            factor = dt / pow(d,p+1);
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

    double minD2 = 4;
    for (i=0;i<N;i++) {
        double d2;
        for (j=i+1;j<N;j++) {
            d2 = distanceSq(&pos[i],&pos[j]);
            if (d2 < minD2) minD2 = d2;
        }
    }
    minD = sqrt(minD2);
    free(newV);
    fprintf(stderr, "%.9f [p=%.5f]\n", minD, p);
}

int
main(int argc, char** argv) {
    int nIter;
    int repeats = 1;
    double friction = 0.16;
    assert(argc >= 3);
    N = atoi(argv[1]);
    nIter = atoi(argv[2]);
    if (argc >= 4) 
       friction = atof(argv[3]);
    pos = malloc(sizeof(vec3)*N);
    assert(pos != NULL);
    // we waste a bit of memory when N is even, but memory is cheap
    v = malloc(sizeof(vec3)*N);
    assert(v != NULL);
    best = malloc(sizeof(vec3)*N);
    assert(best != NULL);
    srand(time(0));
    vec3 origin;
    origin.x = origin.y = origin.z = 0.;
    int i;

// impose antipodal symmetry (or almost if N is odd), using idea of https://math.mit.edu/research/highschool/rsi/documents/2012Gautam.pdf    
    int N0 = (N+1)/2;
    for (i=0;i<N0;i++) {
        do {
            pos[i].x = 1-2*rand() / (RAND_MAX+1.);
            pos[i].y = 1-2*rand() / (RAND_MAX+1.);
            pos[i].z = 1-2*rand() / (RAND_MAX+1.);
        } while (distance(&v[i],&origin) >= 1);
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
    
    fprintf(stderr,"friction=%g\n", friction*N);
    for (i=0;i<nIter;i++) {
        double p = 1+i*(7.-1)/nIter;
        if (p>4.5) p=4.5;
        // 7,4.5,3,10,0 : 0.153
        update(minD/3.+0.00000001, p, friction*N, 0); // 0.0005/N,p); 
        if (minD > bestSoFar) {
            int j;
            for(j=0;j<N;j++) {
                best[j] = pos[j];
            }
            bestSoFar = minD;
        }
    }
    fprintf(stderr,"last=%.9f best=%.9f\n",minD,bestSoFar);
    
    printf("n=%d;\nminD=%.9f;\n", N, bestSoFar);
    printf("points = [");
    for(i=0;i<N;i++) {
        printf("[%.9f,%.9f,%.9f]", best[i].x, best[i].y, best[i].z);
        if (i+1 < N) putchar(',');
    }
    printf ("];\n");
    puts("difference() {sphere(r=1,$fn=100);\nfor(i=[0:len(points)-1]) translate(points[i]) sphere(d=minD,$fn=12);}\n");
    free(best);
    free(pos);
    
    return 0;
}
