export class barItemBean {
  imgNormol: string = ''
  imgSelected: string = ''
  name: string = ''

  constructor(img: string , imgSelected:string , name: string) {
    this.imgNormol = img
    this.imgSelected = imgSelected
    this.name = name
  }
}