defmodule P5 do
  # Library used to manipulate matrices
  import Matrex

  # This function is in charge of starting the secuential execution of the QR Factorization, it receives a square matrix.
  # To create a new matrix: Matrex.random(<length of the diagonal>)
  def givens_rotation(matrix) do
    # Get the dimension of the matrix
    dim = matrix[:rows]
    # Matrex.eye(dim) creates an identity matrix of the dimension specified.
    givens_rotation(matrix, 2, 1, matrix, Matrex.eye(dim))
  end

  #This function calculates the givens rotation for a given matrix and the coordinates of the first number to eliminate.
  #In this case the coordinates are 2,1
  def givens_rotation(matrix, i, j, acc_r, acc_q) do
    # In this part of the process we don't iterate over all of the matrix's values, just over the values on the lower triangular
    # matrix without including the diagonal.
    if(j < matrix[:rows]) do
      if(i <= matrix[:rows]) do
        value = matrix[i][j]

        if value != 0 do
          given_actual = calculate_givens_matrix(acc_r, i, j)

          givens_rotation(
            matrix,
            i + 1,
            j,
            multiply_matrix(given_actual, acc_r),
            multiply_matrix(given_actual, acc_q)
          )
        else
          givens_rotation(matrix, i + 1, j, acc_r, acc_q)
        end
      end

      if(i > matrix[:rows]) do
        givens_rotation(matrix, j + 2, j + 1, acc_r, acc_q)
      end
    else
      q = matrix_t(acc_q)
      r = acc_r
      #IO.inspect("NO PARALLEL ANSWER")
      #IO.inspect(q)
      #IO.inspect(r)
    end
  end

  # This function calculates the givens matrix to eliminate the value on the coordinate i,j the function returns a matrix of the
  # same dimentions of the initial one.
  def calculate_givens_matrix(matrix, i, j) do
    filas = matrix[:rows]
    top = matrix[j][j]
    kill = matrix[i][j]
    hyp = :math.pow(:math.pow(top, 2) + :math.pow(kill, 2), 1 / 2)
    cos = top / hyp
    sen = kill / hyp
    ans = Matrex.eye(filas)
    ans = Matrex.update(ans, i, i, fn _ -> cos end)
    ans = Matrex.update(ans, j, j, fn _ -> cos end)
    ans = Matrex.update(ans, i, j, fn _ -> -sen end)
    Matrex.update(ans, j, i, fn _ -> sen end)
  end

  def matrix_t(matrix) do
    transpose(matrix)
  end

  def multiply_matrix(matrix_1, matrix_2) do
    Matrex.dot(matrix_1, matrix_2)
  end

  #---------------------------------------------------------------------------------------------------------------------

  # This function starts the execution of the parallel implementation of the QR factorization.
  def parallel_givens_rotation(matrix) do
    dim = matrix[:rows]
    parallel_givens_rotation(matrix, 1, 1, 2, 1, matrix, Matrex.eye(dim))
  end

  def parallel_givens_rotation(matrix, first_col, stage, i, j, acc_r, acc_q) do
    # Here we don't iterate over the same values than the secuential implementation, we use a more intelligent approach,
    # we iterate depending on the type given to the value (this is further explained on the document), so we drastically 
    # lowered the number of required iterations.
    if(j < matrix[:rows]) do
      if(i <= matrix[:rows]) do
        # Here we create a list of the processes ids that will execute in a parallel way.
        processes_list = parallel_processes(acc_r, i, j, [])
        givens_matrices = process_givens_matrix(processes_list, Matrex.eye(matrix[:rows]))
        acc_r = multiply_matrix(givens_matrices, acc_r)
        acc_q = multiply_matrix(givens_matrices, acc_q)
        parallel_givens_rotation(matrix, first_col, stage + 1, i + 1, j, acc_r, acc_q)
      end

      if(i > matrix[:rows]) do
        next_i = stage - (first_col + 3)

        if(next_i >= 0) do
          parallel_givens_rotation(
            matrix,
            first_col + 3,
            stage,
            j + 2 + next_i,
            j + 1,
            acc_r,
            acc_q
          )
        else
          parallel_givens_rotation(matrix, first_col + 3, stage, j + 2, j + 1, acc_r, acc_q)
        end
      end
    else
      #IO.inspect("PARALLEL ANSWE")
      q = matrix_t(acc_q)
      r = acc_r
      #IO.inspect(q)
      #IO.inspect(r)
    end
  end

  # Based of the type given to the value, we create a list of process ids that will execute and calculate the givens matrices 
  # corresponding to the values that can be eliminated in a parallel way. We used this approach to know the processes that we
  # have to wait for the other calculations to work.
  def parallel_processes(matrix, i, j, processes_list) do
    if(j <= matrix[:rows] and i <= matrix[:rows] and j < i) do
      if(matrix[i][j] !== 0) do
        processes_list =
          processes_list ++ [Task.async(fn -> calculate_givens_matrix(matrix, i, j) end)]

        parallel_processes(matrix, i - 2, j + 1, processes_list)
      end
    else
      processes_list
    end
  end

  # Thins funtion returns the accumulated value when the list has been processed completely.
  def process_givens_matrix([], acc) do
    acc
  end

  # This function is in charge of getting the results of the processes that executed in parallel and multiplying the matrices
  # in the correct order.
  def process_givens_matrix(processes_list, acc) do
    [head | tail] = processes_list
    current_g = Task.await(head)
    acc = multiply_matrix(current_g, acc)
    process_givens_matrix(tail, acc)
  end
end

# This module was created for the comparison of both implementations
defmodule Time_iterations do

  # This function starts the execution. The parameter received tells the program where to stop running
  def start_test(max_iterations) do
    calculate_time(5, max_iterations)
  end

  # This function creates a random matrix and passes it to both of the problem implementation.
  def calculate_time(matrix_size, max_iterations) when matrix_size <= max_iterations  do
    random_matrix = Matrex.random(matrix_size)
    sec_time = start_secuential(random_matrix)
    par_time = start_parallel(random_matrix)

    IO.puts("#{matrix_size},#{sec_time},#{par_time}")

    calculate_time(matrix_size + 5, max_iterations)
  end

  def calculate_time(matrix_size, max_iterations) do
      IO.inspect("Finished running")
  end 

  # Both functions start executing the implementations and return the time taken to run each of them.

  def start_secuential(random_matrix) do
    start_time = :os.system_time(:millisecond)
    P5.givens_rotation(random_matrix)
    end_time = :os.system_time(:millisecond)
    end_time - start_time
  end

  def start_parallel(random_matrix) do
    start_time = :os.system_time(:millisecond)
    P5.parallel_givens_rotation(random_matrix)
    end_time = :os.system_time(:millisecond)
    end_time - start_time
  end
end