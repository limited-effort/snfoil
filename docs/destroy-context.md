# Destroy Context

Destroy sets up an object using the build functionality, and then attempts to save it to the data source.

Destroy does the following:

- Find a model
- Destroy the model

### Intervals (in order)

<table>
  <thead>
    <th>name</th>
    <th>description</th>
    <th>pre-defined functions</th>
  </thead>

  <tbody>
    <tr>
      <td>setup</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>setup_change</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>setup_destroy</td>
      <td></td>
      <td>Finds the model</td>
    </tr>
    <tr>
      <td>before_change</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>before_destroy</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change_success</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_destroy_success</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change_failure</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_destroy_failure</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_change</td>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>after_destroy</td>
      <td></td>
      <td></td>
    </tr>
  </tbody>
</table>

### ORM Adapter Requirements

The following methods must be defined on the ORM adapter to use the destroy context

- `destroy`
