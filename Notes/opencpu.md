

```r
tv <- function(input){
  #input can either be csv file or data	
  newdata <- if(is.character(input) && file.exists(input)){
    read.csv(input)
  } else {
    as.data.frame(input)
  }
  stopifnot("age" %in% names(newdata))
  stopifnot("marital" %in% names(newdata))
  newdata$age <- as.numeric(newdata$age)

  #tv_model is included with the package
  newdata$tv <- as.vector(mgcv::predict.gam(tv_model, newdata = newdata))
  return(newdata)
}
```

```r
# Score in R
mydata <- data.frame(
  age=c(24, 54, 32, 75),
  marital=c("MARRIED", "DIVORCED", "WIDOWED", "NEVER MARRIED")
)
tvscore::tv(input = mydata)

# Start the single-user development server
opencpu::ocpu_start_server()
#> [2019-03-21 13:46:07] OpenCPU single-user server, version 2.1.1
#> [2019-03-21 13:46:07] Starting 2 new worker(s). Preloading: opencpu, lattice
#> [2019-03-21 13:46:08] READY to serve at: http://localhost:5656/ocpu
#> [2019-03-21 13:46:08] Press ESC or CTRL+C to quit!
```

```
curl http://localhost:5656/ocpu/library/tvscore/R/tv/json \
  -H "Content-Type: application/json" \
  -d '{"input": [{"age":26, "marital":"MARRIED"}, {"age":41, "marital":"DIVORCED"}]}'
#> {
#>   "age": 26,
#>   "marital": "MARRIED",
#>   "tv": 2.9504
#> },
#> {
#>   "age": 41,
#>   "marital": "DIVORCED",
#>   "tv": 2.6154
#> }
```

