# OrderPulse — Page 12 Statistical Findings

## Main business finding

Late deliveries were associated with lower customer review
scores in the historical Olist dataset.

## Consistency checks

- States: 21 of 21 qualifying states showed higher low-review rates for late orders.
- Months: 19 of 19 qualifying months showed the same association.
- State minimum-volume thresholds tested: 30, 50 and 100 orders.

## Buyer-cluster bootstrap

- Resamples: 2,000
- Low-review rate difference: 53.15 percentage points
- 95% interval: [51.88, 54.36] percentage points
- Mean-review score difference: -2.020 points
- 95% interval: [-2.058, -1.981] points

## Review-selection sensitivity

Current versus earliest review selection:

         Policy Delivery group  Reviewed orders  Mean score  Low review %
 Current policy        On time            89443       4.290          9.27
 Current policy           Late             6381       2.270         62.42
Earliest review        On time            89443       4.291          9.26
Earliest review           Late             6381       2.273         62.37

## State-threshold sensitivity

 Minimum orders  States qualifying Highest late-rate state  Highest late rate % Highest late-count state  Late orders in that state
             30                 27                      AL                21.41                       SP                       1820
             50                 26                      AL                21.41                       SP                       1820
            100                 24                      AL                21.41                       SP                       1820

## Limitations

- Observational associations do not prove causation.
- Missing reviews may introduce selection bias.
- Results represent a historical dataset, not live performance.
- Bootstrap intervals reflect sampling variability under the
  customer-cluster resampling assumptions.
- Other variables may influence both delivery performance
  and customer satisfaction.

## Business recommendation

Investigate delivery delays in high-priority states.
Compare routes, fulfillment times and product mix before
testing any operational intervention.

Do not claim a measured improvement before running a pilot.
