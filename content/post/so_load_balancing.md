+++
menu = ""
date = "2017-03-10T12:38:06+01:00"
title = "Exploring Emergent Auto-Scaling"
description = "A pocket-sized experiment to explore the dynamics of emergent auto-scaling"
categories = ["research"]
tags = ["self-organisation", "microservices", "simulation", "python"]
images = []
banner = "images/books.jpg"
+++

I noted that services tend to become smaller and more
intelligent. Microservices for instance now encompass various
resiliency mechanisms such as active queue management (AQM),
auto-scaling or retry/back-off to name only a few. As services are
distributed in nature, I am wondering what behaviour will emerge from
interactions of such autonomous (micro-)services.

While reading "Signals and Boundaries" (Holland 2012), I wonder about
the simplest model that could lead, for instance, to a feature like
auto-scaling. I describe below my shot at it.

# EAS-0, Minimal Emergent Auto-scaling

As a simple example, I concocted EAS-0, the simplest model I could
think of, where autonomous services should scale up and down without
the need for a centralised load-balancer. This model&mdash;a tad
mercantile, in fact venal&mdash;relies on the following assumptions:

 1. *Clients:* 
     
	 1. Each client follows the "publish-find-invoke" principle that
        underlies service-oriented architecture (SOA). Clients first
        query a registry to know available endpoints, and then select
        the one they prefer, for whatever reasons be it price,
        performance, etc. Here, all clients choose the service with
        the shortest response time.
 
 2. *Services:*
 
	 3. Each service processes requests at a fixed rate. When too many
        requests arrive, they are placed in an waiting queue, ideally
        an infinite one. Services process requests in the order they
        arrive.

	 4. Each service publishes its performance (i.e., their expected
        response time) so that clients can decided whether it is a
        good candidate.
 
 3. *Money as Resources*
 
     2. Each service has a budget, in euros for instance.
 
	 3. Each service pays to exist: it shall pay for the time it
        runs. This captures roughly services that rely on cloud
        resources, for which someone gets a bill, eventually.
 
     4. Each service makes money by processing requests. Clients pay a fix
        price per request.
 
 4. *Life and Death*
 
	 5. Once a service is rich enough, it can purchase new resources to
		run a copy of itself. This new instance automatically registers
		so that clients know about it, consequently.
	
	 6. A service dies when it runs out of money. Clients cannot
        invoke it anymore and the remaining requests are marked as
        failed.


# Population Dynamics
To explore the dynamics of the EAS-0 model, I wrote
a
[simulation in Python](https://gist.github.com/fchauvel/e8059c21686d73b18180ab4d62cc5b07). I
am looking to see how well the population of server behaves:

 1. From the perspective of the service providers, that is how many
    servers are up and running, and therefore costing money.
   
 2. From the perspective of the client, that is what is the response
    time of the system.

In the experiment I report below, I used the following initial
conditions:

 * One single server with a budget of 1 &euro;
 * All servers have the same service rate ($r_S$): they all process 2
   req/s.
 * Each request brings in 1.2 &euro; ($m$) ;
 * One second of execution costs 2 &euro; ($c_L$);
 * Reproduction costs a server 10 &euro; ($c_R$);
 * The clients send a total of 50 req/s ($r_A$).
 
 
## Resource Consumption?
Simulations suggest that the total number of server converges toward
the maximal number of servers that can makes profit on a given
workload , that is toward the
[carrying capacity](https://en.wikipedia.org/wiki/Carrying_capacity)
in Ecology. This carrying capacity is the number of server that can
ideally sustain or feed on a given environment, here on a given
arrival rate of requests. In EAS-0, the carrying capacity $C$ is given
by $C = r_A * \frac{m}{c_L}$. In my simulation, for instance, where each
requests brings in 1.2 &euro;, and each second costs 1 &euro;, 10
req/s suffice to sustain 6 servers.

![Fig. 1 Evolution of the number of servers for different living costs](/franck/images/sensitivity_to_living_cost.png)

Fig. 1 shows how the number of servers evolves with different living
cost ($c$). The dashed line show the carrying capacity associated with
each living cost. It suggests that this living cost impacts both the
total number of servers that will eventually survive&mdash;the "steady
state" in Control theory parlance&mdash;but also affects the time it
takes for the system to react&mdash;the raising time.

The purple curve (i.e., $c$ = 2.25 &euro;) may connote the existence
of a "tipping point", beyond which, the system suddenly does not
stabilise anymore.

![Fig. 2 Evolution of the number of servers for different reproduction thresholds.](/franck/images/sensitivity_to_reproduction_threshold.png)

Fig. 2 shows how the population of servers evolves for different
reproduction thresholds ($b_r$). It suggests that the reproduction
threshold also drives up the ''raising time''. This makes sense as,
the more expensive the reproduction, the slower the servers
multiply.

## Response-time

The other important aspect is the response time, from the client's
perspective, especially.

For a single server, the response time is the time it will take to
process all the requests in its queue, plus the request currently under
processing. Formally, we get $t_r = \frac{q_i + 1}{r_S}$, where $q_i$ is the
number of requests in the queue of Agent i, and $r_S$ the service
rate.

![Fig. 3&nbsp;Evolution of the response time for different living cost ($c$)](/franck/images/response_time_vs_living_cost.png)

Fig. 3 portrays how the response time evolves for different cost of
live ($c$). It indicates that the cost of life strongly influences the
time needed for the response time to stabilise. The purple curve ($c$ =
2.25 &euro;) again supports the idea of a tipping point, beyond
which, the response time would not settle down anymore.

![Fig. 4&nbsp;Evolution of the response for different reproduction cost](/franck/images/response_time_vs_reproduction_cost.png)

Fig. 4 illustrates how the response time evolves for several
reproduction thresholds. These results imply that the reproduction
cost also drives the time needed to stabilise the response time, but
that the response time eventually settle down very close to the
individual service time.

# Related Work

I found several attempts to build auto-scaling through self-organisation.

The Scarce framework (Bonvin et al., 2011) also uses "economical
agents" that migrate or provision software components/service to
maximise the utility of these components. These agents, which are
deployed on virtual machines (VM), communicate to reach consensus and
solve a distributed allocation optimisation problem.


# What Next?
The dynamic of EAS-0 is more complicated that I anticipated. It makes
me think of several questions:

 1. Could we build a mathematical model that would capture the
    behaviour of EAS-0?

 1. Could *diversity* helps improve the reaction of the population, as
    bees do to control hive's temperature (Jones et al., 2004). As all
    servers share the same reproduction cost ($c_R$) and service rate
    ($r_S$), generations emerges wherein servers simultaneously
    reproduce, which leads to spikes in the response-time and resource
    consumption.

 3. Service differentiation? What about requests that are not all
    similar, just like service requests that target specific
    operations. Different operation may require more or less
    computational power, and in turn, lead to different service rate.?

# References

Bonvin et al., 2011
: N. Bonvin, T. G. Papaioannou and K. Aberer, 2011. "Autonomic SLA-Driven
  Provisioning for Cloud Applications," In Proceedings of the 11th IEEE/ACM
  International Symposium on Cluster, Cloud and Grid Computing,
  Newport Beach, CA, 2011, pp. 434&ndash;443.

Jones et al., 2004
: Jones, J.C., Myerscough, M.R., Graham, S. and Oldroyd,
  B.P., 2004. Honey bee nest thermoregulation: diversity promotes
  stability. Science, 305(5682), pp.402&ndash;404.

Holland 2012 
: John H. Holland. 2012. Signals and Boundaries: Building Blocks for
  Complex Adaptive Systems. The MIT Press.
