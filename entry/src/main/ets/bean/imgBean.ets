export class imgBean {
  icon: string = '';
  backgroundColor: ResourceColor = '';
  name: string = ''
  description:string = ''

  constructor(icon: string, name: string,description: string) {
    this.icon = icon
    this.name = name
    this.description = description;

  }
}