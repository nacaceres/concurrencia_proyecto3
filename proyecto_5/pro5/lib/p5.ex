defmodule P5 do
  import Matrex

  def givens_rotation(matrix) do
    dim = matrix[:rows]
    givens_rotation(matrix, 2, 1, matrix, Matrex.eye(dim))
  end

  def givens_rotation(matrix, i, j, acc_r, acc_q) do
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
      IO.inspect("NO PARALLEL ANSWER")
      IO.inspect(q)
      IO.inspect(r))
    end
  end

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

  def parallel_givens_rotation(matrix) do
    dim = matrix[:rows]
    parallel_givens_rotation(matrix, 1,1,2, 1, matrix, Matrex.eye(dim))
  end

  def parallel_givens_rotation(matrix, first_col, stage, i, j, acc_r, acc_q) do
    if(j < matrix[:rows]) do
      if(i <= matrix[:rows]) do
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
      IO.inspect("RESPUESTA NO PARALELA")
      q = matrix_t(acc_q)
      r = acc_r
      IO.inspect(q)
      IO.inspect(r)
    end
  end

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

  def process_givens_matrix([], acc) do
    acc
  end

  def process_givens_matrix(processes_list, acc) do
    [head | tail] = processes_list
    current_g = Task.await(head)
    acc = multiply_matrix(current_g, acc)
    process_givens_matrix(tail, acc)
  end
end
