# SugarCpp
SugarCpp is a language which can compile to C++.

## Examples

#### Hello world
```c++
int main() = printf("Hello world!") 
``` 

#### Calculate Sum
```c++
import "stdio.h"

int main()
    sum := 0
    for (i := 1; i < 10; i++)
        sum = sum + i
    printf("sum = %d\n", sum)
```

#### Generic Programming
```c++
T max<T>(x : T, y : T) = x if x > y else y
```

#### Enumerated type
```c++
enum Color = Red | Green | Blue
```

#### Define new variable
```c++
a := 1
b : int
c : int = 0
```

#### Multiple return values​​ && Parallel assignment
```c++
import "stdio.h"
       "tuple"

(T, T) sort<T>(a : T, b : T) = (a,b) if a < b else (b,a)

int main()
	a := 10
	b := 1
    (a, b) = sort(a, b)
    printf("%d %d\n", a, b)
    (a, b) = (b, a)
    printf("%d %d\n", a, b)
```

#### Haskell style infix function
```c++
import "stdio.h"
       "algorithm"

using std::max

int main()
    a := 1
    b := 2
    x := a `max` b
    printf("%d\n", x)
``` 

#### C# style extension method
```c++
import "stdio.h"
       "math.h"

float sqr(x : float) = x * x

int main()
    a := 100
    x := a :sqrt() :sqr()
    printf("%f\n", x)
```

#### Namespace
```c++
namespace SugarCpp::AstNode::Expr
    struct ExprBin
        Left, Right : Expr
        Op : string

```